package handler

// * +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// * Copyright 2023 The Geek-AI Authors. All rights reserved.
// * Use of this source code is governed by a Apache-2.0 license
// * that can be found in the LICENSE file.
// * @Author yangjian102621@163.com
// * +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

import (
	"encoding/base64"
	"fmt"
	"geekai/core"
	"geekai/core/types"
	"geekai/service"
	"geekai/service/mj"
	"geekai/service/oss"
	"geekai/store/model"
	"geekai/store/vo"
	"geekai/utils"
	"geekai/utils/resp"
	"net/http"
	"strings"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/gorilla/websocket"
	"gorm.io/gorm"
)

type MidJourneyHandler struct {
	BaseHandler
	pool      *mj.ServicePool
	snowflake *service.Snowflake
	uploader  *oss.UploaderManager
}

func NewMidJourneyHandler(app *core.AppServer, db *gorm.DB, snowflake *service.Snowflake, pool *mj.ServicePool, manager *oss.UploaderManager) *MidJourneyHandler {
	return &MidJourneyHandler{
		snowflake: snowflake,
		pool:      pool,
		uploader:  manager,
		BaseHandler: BaseHandler{
			App: app,
			DB:  db,
		},
	}
}

func (h *MidJourneyHandler) preCheck(c *gin.Context) bool {
	user, err := h.GetLoginUser(c)
	if err != nil {
		resp.NotAuth(c)
		return false
	}

	if user.Power < h.App.SysConfig.MjPower {
		resp.ERROR(c, "当前用户剩余算力不足以完成本次绘画！")
		return false
	}

	if !h.pool.HasAvailableService() {
		resp.ERROR(c, "MidJourney 池子中没有没有可用的服务！")
		return false
	}

	return true

}

// Client WebSocket 客户端，用于通知任务状态变更
func (h *MidJourneyHandler) Client(c *gin.Context) {
	ws, err := (&websocket.Upgrader{CheckOrigin: func(r *http.Request) bool { return true }}).Upgrade(c.Writer, c.Request, nil)
	if err != nil {
		logger.Error(err)
		c.Abort()
		return
	}

	userId := h.GetInt(c, "user_id", 0)
	if userId == 0 {
		logger.Info("Invalid user ID")
		c.Abort()
		return
	}

	client := types.NewWsClient(ws)
	h.pool.Clients.Put(uint(userId), client)
	logger.Infof("New websocket connected, IP: %s", c.RemoteIP())
}

// Image 创建一个绘画任务
func (h *MidJourneyHandler) Image(c *gin.Context) {
	var data struct {
		TaskType  string   `json:"task_type"`
		Prompt    string   `json:"prompt"`
		NegPrompt string   `json:"neg_prompt"`
		Rate      string   `json:"rate"`
		Model     string   `json:"model"`   // 模型
		Chaos     int      `json:"chaos"`   // 创意度取值范围: 0-100
		Raw       bool     `json:"raw"`     // 是否开启原始模型
		Seed      int64    `json:"seed"`    // 随机数
		Stylize   int      `json:"stylize"` // 风格化
		ImgArr    []string `json:"img_arr"`
		Tile      bool     `json:"tile"`    // 重复平铺
		Quality   float32  `json:"quality"` // 画质
		Iw        float32  `json:"iw"`
		CRef      string   `json:"cref"` //生成角色一致的图像
		SRef      string   `json:"sref"` //生成风格一致的图像
		Cw        int      `json:"cw"`   // 参考程度
	}
	if err := c.ShouldBindJSON(&data); err != nil {
		resp.ERROR(c, types.InvalidArgs)
		return
	}
	if !h.preCheck(c) {
		return
	}

	var params = ""
	if data.Rate != "" && !strings.Contains(params, "--ar") {
		params += " --ar " + data.Rate
	}
	if data.Seed > 0 && !strings.Contains(params, "--seed") {
		params += fmt.Sprintf(" --seed %d", data.Seed)
	}
	if data.Stylize > 0 && !strings.Contains(params, "--s") && !strings.Contains(params, "--stylize") {
		params += fmt.Sprintf(" --s %d", data.Stylize)
	}
	if data.Chaos > 0 && !strings.Contains(params, "--c") && !strings.Contains(params, "--chaos") {
		params += fmt.Sprintf(" --c %d", data.Chaos)
	}
	if len(data.ImgArr) > 0 && data.Iw > 0 {
		params += fmt.Sprintf(" --iw %.2f", data.Iw)
	}
	if data.Raw {
		params += " --style raw"
	}
	if data.Quality > 0 {
		params += fmt.Sprintf(" --q %.2f", data.Quality)
	}
	if data.Tile {
		params += " --tile "
	}
	if data.CRef != "" {
		params += fmt.Sprintf(" --cref %s", data.CRef)
		if data.Cw > 0 {
			params += fmt.Sprintf(" --cw %d", data.Cw)
		} else {
			params += " --cw 100"
		}
	}

	if data.SRef != "" {
		params += fmt.Sprintf(" --sref %s", data.SRef)
	}
	if data.Model != "" && !strings.Contains(params, "--v") && !strings.Contains(params, "--niji") {
		params += fmt.Sprintf(" %s", data.Model)
	}

	// 处理融图和换脸的提示词
	if data.TaskType == types.TaskSwapFace.String() || data.TaskType == types.TaskBlend.String() {
		params = fmt.Sprintf("%s:%s", data.TaskType, strings.Join(data.ImgArr, ","))
	}

	// 如果本地图片上传的是相对地址，处理成绝对地址
	for k, v := range data.ImgArr {
		if !strings.HasPrefix(v, "http") {
			data.ImgArr[k] = fmt.Sprintf("http://localhost:5678/%s", strings.TrimLeft(v, "/"))
		}
	}

	idValue, _ := c.Get(types.LoginUserID)
	userId := utils.IntValue(utils.InterfaceToString(idValue), 0)
	// generate task id
	taskId, err := h.snowflake.Next(true)
	if err != nil {
		resp.ERROR(c, "error with generate task id: "+err.Error())
		return
	}
	job := model.MidJourneyJob{
		Type:      data.TaskType,
		UserId:    userId,
		TaskId:    taskId,
		Progress:  0,
		Prompt:    fmt.Sprintf("%s %s", data.Prompt, params),
		Power:     h.App.SysConfig.MjPower,
		CreatedAt: time.Now(),
	}
	opt := "绘图"
	if data.TaskType == types.TaskBlend.String() {
		job.Prompt = "融图：" + strings.Join(data.ImgArr, ",")
		opt = "融图"
	} else if data.TaskType == types.TaskSwapFace.String() {
		job.Prompt = "换脸：" + strings.Join(data.ImgArr, ",")
		opt = "换脸"
	}

	if res := h.DB.Create(&job); res.Error != nil || res.RowsAffected == 0 {
		resp.ERROR(c, "添加任务失败："+res.Error.Error())
		return
	}

	h.pool.PushTask(types.MjTask{
		Id:        job.Id,
		TaskId:    taskId,
		Type:      types.TaskType(data.TaskType),
		Prompt:    data.Prompt,
		NegPrompt: data.NegPrompt,
		Params:    params,
		UserId:    userId,
		ImgArr:    data.ImgArr,
	})

	client := h.pool.Clients.Get(uint(job.UserId))
	if client != nil {
		_ = client.Send([]byte("Task Updated"))
	}

	// update user's power
	tx := h.DB.Model(&model.User{}).Where("id = ?", job.UserId).UpdateColumn("power", gorm.Expr("power - ?", job.Power))
	// 记录算力变化日志
	if tx.Error == nil && tx.RowsAffected > 0 {
		user, _ := h.GetLoginUser(c)
		h.DB.Create(&model.PowerLog{
			UserId:    user.Id,
			Username:  user.Username,
			Type:      types.PowerConsume,
			Amount:    job.Power,
			Balance:   user.Power - job.Power,
			Mark:      types.PowerSub,
			Model:     "mid-journey",
			Remark:    fmt.Sprintf("%s操作，任务ID：%s", opt, job.TaskId),
			CreatedAt: time.Now(),
		})
	}
	resp.SUCCESS(c)
}

type reqVo struct {
	Index       int    `json:"index"`
	ChannelId   string `json:"channel_id"`
	MessageId   string `json:"message_id"`
	MessageHash string `json:"message_hash"`
}

// Upscale send upscale command to MidJourney Bot
func (h *MidJourneyHandler) Upscale(c *gin.Context) {
	var data reqVo
	if err := c.ShouldBindJSON(&data); err != nil {
		resp.ERROR(c, types.InvalidArgs)
		return
	}

	if !h.preCheck(c) {
		return
	}

	idValue, _ := c.Get(types.LoginUserID)
	userId := utils.IntValue(utils.InterfaceToString(idValue), 0)
	taskId, _ := h.snowflake.Next(true)
	job := model.MidJourneyJob{
		Type:        types.TaskUpscale.String(),
		ReferenceId: data.MessageId,
		UserId:      userId,
		TaskId:      taskId,
		Progress:    0,
		Power:       h.App.SysConfig.MjActionPower,
		CreatedAt:   time.Now(),
	}
	if res := h.DB.Create(&job); res.Error != nil || res.RowsAffected == 0 {
		resp.ERROR(c, "添加任务失败："+res.Error.Error())
		return
	}

	h.pool.PushTask(types.MjTask{
		Id:          job.Id,
		Type:        types.TaskUpscale,
		UserId:      userId,
		ChannelId:   data.ChannelId,
		Index:       data.Index,
		MessageId:   data.MessageId,
		MessageHash: data.MessageHash,
	})

	client := h.pool.Clients.Get(uint(job.UserId))
	if client != nil {
		_ = client.Send([]byte("Task Updated"))
	}
	// update user's power
	tx := h.DB.Model(&model.User{}).Where("id = ?", job.UserId).UpdateColumn("power", gorm.Expr("power - ?", job.Power))
	// 记录算力变化日志
	if tx.Error == nil && tx.RowsAffected > 0 {
		user, _ := h.GetLoginUser(c)
		h.DB.Create(&model.PowerLog{
			UserId:    user.Id,
			Username:  user.Username,
			Type:      types.PowerConsume,
			Amount:    job.Power,
			Balance:   user.Power - job.Power,
			Mark:      types.PowerSub,
			Model:     "mid-journey",
			Remark:    fmt.Sprintf("Upscale 操作，任务ID：%s", job.TaskId),
			CreatedAt: time.Now(),
		})
	}
	resp.SUCCESS(c)
}

// Variation send variation command to MidJourney Bot
func (h *MidJourneyHandler) Variation(c *gin.Context) {
	var data reqVo
	if err := c.ShouldBindJSON(&data); err != nil {
		resp.ERROR(c, types.InvalidArgs)
		return
	}

	if !h.preCheck(c) {
		return
	}

	idValue, _ := c.Get(types.LoginUserID)
	userId := utils.IntValue(utils.InterfaceToString(idValue), 0)
	taskId, _ := h.snowflake.Next(true)
	job := model.MidJourneyJob{
		Type:        types.TaskVariation.String(),
		ChannelId:   data.ChannelId,
		ReferenceId: data.MessageId,
		UserId:      userId,
		TaskId:      taskId,
		Progress:    0,
		Power:       h.App.SysConfig.MjActionPower,
		CreatedAt:   time.Now(),
	}
	if res := h.DB.Create(&job); res.Error != nil || res.RowsAffected == 0 {
		resp.ERROR(c, "添加任务失败："+res.Error.Error())
		return
	}

	h.pool.PushTask(types.MjTask{
		Id:          job.Id,
		Type:        types.TaskVariation,
		UserId:      userId,
		Index:       data.Index,
		ChannelId:   data.ChannelId,
		MessageId:   data.MessageId,
		MessageHash: data.MessageHash,
	})

	client := h.pool.Clients.Get(uint(job.UserId))
	if client != nil {
		_ = client.Send([]byte("Task Updated"))
	}

	// update user's power
	tx := h.DB.Model(&model.User{}).Where("id = ?", job.UserId).UpdateColumn("power", gorm.Expr("power - ?", job.Power))
	// 记录算力变化日志
	if tx.Error == nil && tx.RowsAffected > 0 {
		user, _ := h.GetLoginUser(c)
		h.DB.Create(&model.PowerLog{
			UserId:    user.Id,
			Username:  user.Username,
			Type:      types.PowerConsume,
			Amount:    job.Power,
			Balance:   user.Power - job.Power,
			Mark:      types.PowerSub,
			Model:     "mid-journey",
			Remark:    fmt.Sprintf("Variation 操作，任务ID：%s", job.TaskId),
			CreatedAt: time.Now(),
		})
	}
	resp.SUCCESS(c)
}

// ImgWall 照片墙
func (h *MidJourneyHandler) ImgWall(c *gin.Context) {
	page := h.GetInt(c, "page", 0)
	pageSize := h.GetInt(c, "page_size", 0)
	err, jobs := h.getData(true, 0, page, pageSize, true)
	if err != nil {
		resp.ERROR(c, err.Error())
		return
	}

	resp.SUCCESS(c, jobs)
}

// JobList 获取 MJ 任务列表
func (h *MidJourneyHandler) JobList(c *gin.Context) {
	finish := h.GetBool(c, "finish")
	userId := h.GetLoginUserId(c)
	page := h.GetInt(c, "page", 0)
	pageSize := h.GetInt(c, "page_size", 0)
	publish := h.GetBool(c, "publish")

	err, jobs := h.getData(finish, userId, page, pageSize, publish)
	if err != nil {
		resp.ERROR(c, err.Error())
		return
	}

	resp.SUCCESS(c, jobs)
}

// JobList 获取 MJ 任务列表
func (h *MidJourneyHandler) getData(finish bool, userId uint, page int, pageSize int, publish bool) (error, []vo.MidJourneyJob) {
	session := h.DB.Session(&gorm.Session{})
	if finish {
		session = session.Where("progress >= ?", 100).Order("id DESC")
	} else {
		session = session.Where("progress < ?", 100).Order("id ASC")
	}
	if userId > 0 {
		session = session.Where("user_id = ?", userId)
	}
	if publish {
		session = session.Where("publish = ?", publish)
	}
	if page > 0 && pageSize > 0 {
		offset := (page - 1) * pageSize
		session = session.Offset(offset).Limit(pageSize)
	}

	var items []model.MidJourneyJob
	res := session.Find(&items)
	if res.Error != nil {
		return res.Error, nil
	}

	var jobs = make([]vo.MidJourneyJob, 0)
	for _, item := range items {
		var job vo.MidJourneyJob
		err := utils.CopyObject(item, &job)
		if err != nil {
			continue
		}

		if item.Progress < 100 && item.ImgURL == "" && item.OrgURL != "" {
			image, err := utils.DownloadImage(item.OrgURL, h.App.Config.ProxyURL)
			if err == nil {
				job.ImgURL = "data:image/png;base64," + base64.StdEncoding.EncodeToString(image)
			}
		}

		jobs = append(jobs, job)
	}
	return nil, jobs
}

// Remove remove task image
func (h *MidJourneyHandler) Remove(c *gin.Context) {
	id := h.GetInt(c, "id", 0)
	userId := h.GetInt(c, "user_id", 0)
	var job model.MidJourneyJob
	if res := h.DB.Where("id = ? AND user_id = ?", id, userId).First(&job); res.Error != nil {
		resp.ERROR(c, "记录不存在")
		return
	}

	// remove job recode
	tx := h.DB.Begin()
	if err := tx.Delete(&job).Error; err != nil {
		tx.Rollback()
		resp.ERROR(c, err.Error())
		return
	}

	// 如果任务未完成，或者任务失败，则恢复用户算力
	if job.Progress != 100 {
		err := tx.Model(&model.User{}).Where("id = ?", job.UserId).UpdateColumn("power", gorm.Expr("power + ?", job.Power)).Error
		if err != nil {
			tx.Rollback()
			resp.ERROR(c, err.Error())
			return
		}
		var user model.User
		h.DB.Where("id = ?", job.UserId).First(&user)
		err = tx.Create(&model.PowerLog{
			UserId:    user.Id,
			Username:  user.Username,
			Type:      types.PowerConsume,
			Amount:    job.Power,
			Balance:   user.Power,
			Mark:      types.PowerAdd,
			Model:     "mid-journey",
			Remark:    fmt.Sprintf("绘画任务失败，退回算力。任务ID：%s，Err: %s", job.TaskId, job.ErrMsg),
			CreatedAt: time.Now(),
		}).Error
		if err != nil {
			tx.Rollback()
			resp.ERROR(c, err.Error())
			return
		}
	}
	tx.Commit()

	// remove image
	err := h.uploader.GetUploadHandler().Delete(job.ImgURL)
	if err != nil {
		logger.Error("remove image failed: ", err)
	}

	client := h.pool.Clients.Get(uint(job.UserId))
	if client != nil {
		_ = client.Send([]byte("Task Updated"))
	}

	resp.SUCCESS(c)
}

// Publish 发布图片到画廊显示
func (h *MidJourneyHandler) Publish(c *gin.Context) {
	id := h.GetInt(c, "id", 0)
	userId := h.GetInt(c, "user_id", 0)
	action := h.GetBool(c, "action") // 发布动作，true => 发布，false => 取消分享
	res := h.DB.Model(&model.MidJourneyJob{Id: uint(id), UserId: userId}).UpdateColumn("publish", action)
	if res.Error != nil {
		logger.Error("error with update database：", res.Error)
		resp.ERROR(c, "更新数据库失败")
		return
	}

	resp.SUCCESS(c)
}
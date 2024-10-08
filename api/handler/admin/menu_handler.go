package admin

// * +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// * Copyright 2023 The Geek-AI Authors. All rights reserved.
// * Use of this source code is governed by a Apache-2.0 license
// * that can be found in the LICENSE file.
// * @Author yangjian102621@163.com
// * +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

import (
	"geekai/core"
	"geekai/core/types"
	"geekai/handler"
	"geekai/store/model"
	"geekai/store/vo"
	"geekai/utils"
	"geekai/utils/resp"
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

type MenuHandler struct {
	handler.BaseHandler
}

func NewMenuHandler(app *core.AppServer, db *gorm.DB) *MenuHandler {
	return &MenuHandler{BaseHandler: handler.BaseHandler{App: app, DB: db}}
}

func (h *MenuHandler) Save(c *gin.Context) {
	var data struct {
		Id      uint   `json:"id"`
		Name    string `json:"name"`
		Icon    string `json:"icon"`
		URL     string `json:"url"`
		SortNum int    `json:"sort_num"`
		Enabled bool   `json:"enabled"`
	}
	if err := c.ShouldBindJSON(&data); err != nil {
		resp.ERROR(c, types.InvalidArgs)
		return
	}

	err := h.DB.Save(&model.Menu{
		Id:      data.Id,
		Name:    data.Name,
		Icon:    data.Icon,
		URL:     data.URL,
		SortNum: data.SortNum,
		Enabled: data.Enabled,
	}).Error
	if err != nil {
		resp.ERROR(c, err.Error())
		return
	}
	resp.SUCCESS(c)
}

// List 数据列表
func (h *MenuHandler) List(c *gin.Context) {
	var items []model.Menu
	var list = make([]vo.Menu, 0)
	res := h.DB.Order("sort_num ASC").Find(&items)
	if res.Error == nil {
		for _, item := range items {
			var product vo.Menu
			err := utils.CopyObject(item, &product)
			if err == nil {
				list = append(list, product)
			}
		}
	}
	resp.SUCCESS(c, list)
}

func (h *MenuHandler) Enable(c *gin.Context) {
	var data struct {
		Id      uint `json:"id"`
		Enabled bool `json:"enabled"`
	}

	if err := c.ShouldBindJSON(&data); err != nil {
		resp.ERROR(c, types.InvalidArgs)
		return
	}

	err := h.DB.Model(&model.Menu{}).Where("id", data.Id).UpdateColumn("enabled", data.Enabled).Error
	if err != nil {
		resp.ERROR(c, err.Error())
		return
	}
	resp.SUCCESS(c)
}

func (h *MenuHandler) Sort(c *gin.Context) {
	var data struct {
		Ids   []uint `json:"ids"`
		Sorts []int  `json:"sorts"`
	}

	if err := c.ShouldBindJSON(&data); err != nil {
		resp.ERROR(c, types.InvalidArgs)
		return
	}

	for index, id := range data.Ids {
		err := h.DB.Model(&model.Menu{}).Where("id", id).Update("sort_num", data.Sorts[index]).Error
		if err != nil {
			resp.ERROR(c, err.Error())
			return
		}
	}

	resp.SUCCESS(c)
}

func (h *MenuHandler) Remove(c *gin.Context) {
	id := h.GetInt(c, "id", 0)

	if id > 0 {
		err := h.DB.Where("id", id).Delete(&model.Menu{}).Error
		if err != nil {
			resp.ERROR(c, err.Error())
			return
		}
	}
	resp.SUCCESS(c)
}

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
	"time"
)

type ProductHandler struct {
	handler.BaseHandler
}

func NewProductHandler(app *core.AppServer, db *gorm.DB) *ProductHandler {
	return &ProductHandler{BaseHandler: handler.BaseHandler{App: app, DB: db}}
}

func (h *ProductHandler) Save(c *gin.Context) {
	var data struct {
		Id        uint    `json:"id"`
		Name      string  `json:"name"`
		Price     float64 `json:"price"`
		Discount  float64 `json:"discount"`
		Enabled   bool    `json:"enabled"`
		Days      int     `json:"days"`
		Power     int     `json:"power"`
		CreatedAt int64   `json:"created_at"`
	}
	if err := c.ShouldBindJSON(&data); err != nil {
		resp.ERROR(c, types.InvalidArgs)
		return
	}

	item := model.Product{
		Name:     data.Name,
		Price:    data.Price,
		Discount: data.Discount,
		Days:     data.Days,
		Power:    data.Power,
		Enabled:  data.Enabled}
	item.Id = data.Id
	if item.Id > 0 {
		item.CreatedAt = time.Unix(data.CreatedAt, 0)
	}
	err := h.DB.Save(&item).Error
	if err != nil {
		resp.ERROR(c, err.Error())
		return
	}

	var itemVo vo.Product
	err = utils.CopyObject(item, &itemVo)
	if err != nil {
		resp.ERROR(c, "数据拷贝失败: "+err.Error())
		return
	}
	itemVo.Id = item.Id
	itemVo.UpdatedAt = item.UpdatedAt.Unix()
	resp.SUCCESS(c, itemVo)
}

// List 数据列表
func (h *ProductHandler) List(c *gin.Context) {
	var items []model.Product
	var list = make([]vo.Product, 0)
	res := h.DB.Order("sort_num ASC").Find(&items)
	if res.Error == nil {
		for _, item := range items {
			var product vo.Product
			err := utils.CopyObject(item, &product)
			if err == nil {
				product.Id = item.Id
				product.CreatedAt = item.CreatedAt.Unix()
				product.UpdatedAt = item.UpdatedAt.Unix()
				list = append(list, product)
			} else {
				logger.Error(err)
			}
		}
	}
	resp.SUCCESS(c, list)
}

func (h *ProductHandler) Enable(c *gin.Context) {
	var data struct {
		Id      uint `json:"id"`
		Enabled bool `json:"enabled"`
	}

	if err := c.ShouldBindJSON(&data); err != nil {
		resp.ERROR(c, types.InvalidArgs)
		return
	}

	err := h.DB.Model(&model.Product{}).Where("id", data.Id).UpdateColumn("enabled", data.Enabled).Error
	if err != nil {
		resp.ERROR(c, err.Error())
		return
	}
	resp.SUCCESS(c)
}

func (h *ProductHandler) Sort(c *gin.Context) {
	var data struct {
		Ids   []uint `json:"ids"`
		Sorts []int  `json:"sorts"`
	}

	if err := c.ShouldBindJSON(&data); err != nil {
		resp.ERROR(c, types.InvalidArgs)
		return
	}

	for index, id := range data.Ids {
		err := h.DB.Model(&model.Product{}).Where("id", id).Update("sort_num", data.Sorts[index]).Error
		if err != nil {
			resp.ERROR(c, err.Error())
			return
		}
	}

	resp.SUCCESS(c)
}

func (h *ProductHandler) Remove(c *gin.Context) {
	id := h.GetInt(c, "id", 0)

	if id > 0 {
		err := h.DB.Where("id", id).Delete(&model.Product{}).Error
		if err != nil {
			resp.ERROR(c, err.Error())
			return
		}
	}
	resp.SUCCESS(c)
}

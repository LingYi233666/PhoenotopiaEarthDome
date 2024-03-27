local Screen = require "widgets/screen"
local TEMPLATES = require "widgets/redux/templates"
local Widget = require "widgets/widget"
local Text = require "widgets/text"
local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"
local Grid = require "widgets/grid"
local PopupDialogScreen = require "screens/redux/popupdialog"

local define_sort = {
    "melody_ouroboros",
    "melody_geo",
    "melody_royal",
    "melody_panselo",
    "melody_battle",
    "melody_phoenix",
}

local GaleFluteList = Class(Widget,function(self,scroll_data)
    Widget._ctor(self, "GaleFluteList")

    self.scroll_data = scroll_data

    self:AddItemsAndList()
end)

function GaleFluteList:AddItemsAndList()
    self.data = {}
    for _,v in pairs(define_sort) do
        table.insert(self.data,{
            name = v,
            define = TUNING.GALE_MELODY_DEFINE[v],
        })
    end

    self.scroll_list = self:AddChild(TEMPLATES.ScrollingGrid(
        self.data,
        {
            context = {},
            widget_width  = self.scroll_data.widget_width,
            widget_height = self.scroll_data.widget_height,
            num_visible_rows = 6,
            num_columns      = 1,
            item_ctor_fn = function(context, i)
                local label = Widget("label")
                local label_root = label:AddChild(Widget("label_root"))

                label_root.bg = label_root:AddChild(TEMPLATES.ListItemBackground(
                    self.scroll_data.widget_width, 
                    self.scroll_data.widget_height,function()
                        TheFrontEnd:PushScreen(PopupDialogScreen(
                            STRINGS.GALE_MELODIES.NAME[label.melody_name:upper()],
                            STRINGS.GALE_MELODIES.DESC[label.melody_name:upper()],
                            {
                                {
                                    text = STRINGS.UI.MAINSCREEN.OK,
                                    cb = function()
                                        TheFrontEnd:PopScreen()
                                    end
                                }
                            }
                        ))
                    end
                ))

                label_root.bg:SetImageNormalColour(1,1,1,0.9)
                label_root.bg:SetImageFocusColour(1,1,1,1)
                label_root.bg:SetImageSelectedColour(1,1,1,0.9)
                label_root.bg:SetImageDisabledColour(1,1,1,0.9)
                
                label_root.medloy_img = label_root:AddChild(Image())

                label_root.title = label_root:AddChild(Text(HEADERFONT, 35))
                label_root.title:SetVAlign(ANCHOR_TOP)
                label_root.title:SetHAlign(ANCHOR_LEFT)

                label_root.grid = label_root:AddChild(Grid())


                label.SetText = function(_, new_label)
                    label_root.title:SetString(new_label)
                end

                label.SetTexture = function(_,xml,tex)
                    label_root.medloy_img:SetTexture(xml,tex)
                end

                label.FillFluteGrid = function(_,flute_define)
                    local widgets = {}
                    for k,v in pairs(flute_define) do
                        local ui = label_root:AddChild(Image("images/ui/flute/"..v..".xml",v..".tex"))
                        ui:SetSize(self.scroll_data.flute_wh,self.scroll_data.flute_wh)
                        table.insert(widgets,ui)
                    end

                    label_root.grid:FillGrid(#widgets,self.scroll_data.flute_wh + 8,self.scroll_data.flute_wh,widgets)
                end

                label.MakeLayout = function(_)
                    local img_wh = math.min(self.scroll_data.widget_width / 3.5,self.scroll_data.widget_height - 15)
                    -- local img_wh = 50
                    local img_pos_x = -self.scroll_data.widget_width / 2 + img_wh / 2 + 15
                    label_root.medloy_img:SetSize(img_wh,img_wh)
                    label_root.medloy_img:SetPosition(img_pos_x,0)

                    local text_w,text_h = label_root.title:GetRegionSize()

                    local text_pos_x = math.min(0,img_pos_x + img_wh / 2 + text_w / 2 + 15)
                    local text_pos_y = self.scroll_data.widget_height / 2 - text_h / 2 - 10
                    label_root.title:SetPosition(text_pos_x,text_pos_y)

                    local grid_pos_x = img_pos_x + img_wh / 2 + self.scroll_data.flute_wh / 2 + 15
                    local grid_pos_y = -self.scroll_data.widget_height / 2 + self.scroll_data.flute_wh / 2  + 15
                    label_root.grid:SetPosition(grid_pos_x,grid_pos_y)
                end

                label.focus_forward = label_root.bg

                return label

            end,
            apply_fn     = function(context, widget, data, index)
                if widget == nil then
                    return
                elseif data == nil then
                    widget:Hide()
                    return
                else
                    widget:Show()
                end

                widget.melody_name = data.name:upper()

                widget:SetText(STRINGS.GALE_MELODIES.NAME[data.name:upper()])


                widget:SetTexture("images/ui/melody/"..data.name:lower()..".xml",data.name:lower()..".tex")

                widget:FillFluteGrid(data.define)
                
                widget:MakeLayout()
            end,
            scrollbar_offset = 15,
            scrollbar_height_offset = 0,
        }
    ))
end

return GaleFluteList
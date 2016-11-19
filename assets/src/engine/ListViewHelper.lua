----------------------------------------------------------------------
-- 作者：lewis
-- 日期：2015-09-26
-- 描述：list view helper
----------------------------------------------------------------------

ListViewHelper = class("ListViewHelper", function() return ccui.ListView:create() end)

function ListViewHelper:ctor()
    self.item_cls = nil
    self.cell_size = nil
    self.single_cell_size = nil
    self.mDataList = {}
    self.total = 0
    self.load_count = 0
    self.node_list = {}
    self.item_list = {}
    self.interval_load = false  -- 间断填充
    self.next_update_handler = nil
	self:setScrollBarEnabled(false)
end

function ListViewHelper:init()
    self:calcTotal()
    for i = 1, self.total do
        local node = self:addCustomItem()
        table.insert(self.node_list, node)
    end
    self:calcTotal()
    local function update() 
        self:onUpdate() 
    end
    local node = cc.Node:create()
    self:addChild(node)
    node:scheduleUpdateWithPriorityLua(update, 0.1)
end

function ListViewHelper:setMargin(mar)
    self:setItemsMargin(mar)
    self.items_margin = mar
end

function ListViewHelper:onUpdate()
    if self.next_update_handler then
        self.next_update_handler()
        self.next_update_handler = nil
    end
    self.load_count = 0
    self:updateItems()
    if self.load_count > 0 then
        print("list view load cnt", self.load_count)
    end
end

function ListViewHelper:calcTotal()
    local total = #self.mDataList
    total = math.ceil(total / self.cpr)
    self.total = total
    return total
end

function ListViewHelper:addCustomItem()
    local node = ccui.Layout:create()
    node:setContentSize(self.cell_size)
    node.item = false
    node.dirty = false
    self:pushBackCustomItem(node)
    return node
end

function ListViewHelper:getNode(idx)
    return self.node_list[idx + 1]
end

-- 创建子结点
function ListViewHelper:createItem(node, index)
    if self:getDirection() == ccui.ScrollViewDir.vertical then
        self:createVerticalItem(node, index)
    else
        self:createHorizontalItem(node, index)
    end
end

function ListViewHelper:createCell()
    local item = self.item_cls.new()
    if not IsKindOf(self.item_cls, "Component") then
        ExtendClass(item, Component)
    end
    item.mListView = self
    item.mGameOject = self.mGameOject
    item:init()
    return item
end

-- 创建水平方向的(垂直多项)
function ListViewHelper:createHorizontalItem(node, index)
    local y = 0
    index = index * self.cpr
    local height = self.cell_size.height / self.cpr
    if self.single_cell_size then
         local offset = (self.cell_size.height - self.single_cell_size.height * self.cpr) / (self.cpr + 1)
         height = self.single_cell_size.height + offset
         y = offset
    end
    y = y + (self.cpr - 1) * height
    node.list = {}
    for i = 1, self.cpr do
        local idx = index + i
        local data = self.mDataList[idx]
        --print("list view item idx", idx)
        local item = self:createCell()
        table.insert(self.item_list, item)
        node:addChild(item)
        item:setPositionY(y)
        item:setVisible(false)
        if data then
            item:setVisible(true)
            item:updateCell(data, idx)
        end
        y = y - height
        table.insert(node.list, item)
        self.load_count = self.load_count + 1
    end
    node.item = true
    node.dirty = false
end

-- 创建垂直方向(水平多项)
function ListViewHelper:createVerticalItem(node, index)
    local x = 0
    index = index * self.cpr
    local width = self.cell_size.width / self.cpr
    if self.single_cell_size then
         local offset = (self.cell_size.width - self.single_cell_size.width * self.cpr) / (self.cpr + 1)
         width = self.single_cell_size.width + offset
         x = offset
    end
    node.list = {}
    for i = 1, self.cpr do
        local idx = index + i
        local data = self.mDataList[idx]
        local item = self:createCell()
        table.insert(self.item_list, item)
        node:addChild(item)
        item:setPositionX(x)
        item:setVisible(false)
        if data then
            item:setVisible(true)
            item:updateCell(data, idx)
        end
        x = x + width
        table.insert(node.list, item)
        self.load_count = self.load_count + 1
    end
    node.item = true
    node.dirty = false
end

function ListViewHelper:refreshItem(node, index)
    local idx = 1
    index = index * self.cpr
    for _, val in pairs(node.list) do
        local data = self.mDataList[index + idx]
        if data then
            val:setVisible(true)
            val:updateCell(data, index + idx)
        else
            val:setVisible(false)
        end
        idx = idx + 1
    end
    node.dirty = false
end

-- 重新加载数据
function ListViewHelper:reloadData(list, bOriginPos)
    local items = self:getItems()
    for _, node in pairs(items) do
        node.dirty = true
    end
    if list == nil then return end
    local old = self.total
    self.mDataList = list
    local new = self:calcTotal()
    local distance = new - old
    --print("distance", distance, old, new)
    if distance == 0 then return end
    if distance > 0 then
        for i = 1, distance do
            local node = self:addCustomItem()
            table.insert(self.node_list, node)
        end
    else
        distance = math.abs(distance)
        for i = 1, distance do
            self:removeLastItem()
            table.remove(self.node_list, #self.node_list)
        end
    end
    -- 回到起引位置
    if bOriginPos then
        self:backToOriginPos()
    end
end

-- 滚动到cell
function ListViewHelper:scrollToCell(idx, duration)
    local percent = 0
    local dir = self:getDirection()
    local margin = self.items_margin
    if dir == ccui.ScrollViewDir.vertical then
        local distance = (self.cell_size.height + margin) * self.total - self:getContentSize().height
        if distance < 0 then
            return
        end
        local offset = (idx - 1) * (self.cell_size.height + margin)
        percent = offset / distance * 100
    elseif dir == ccui.ScrollViewDir.horizontal then
        local distance = (self.cell_size.width + margin) * self.total - self:getContentSize().width
        if distance < 0 then
            return
        end
        local offset = (idx - 1) * (self.cell_size.width + margin)
        percent = offset / distance * 100
        print(idx, distance, offset)
    end
    if percent > 100 then percent = 100 end
    --MsgBox(percent)
    --print("scrollToCell", percent)
    self.next_update_handler = function() self:implScrollToCell(percent, duration) end
end

function ListViewHelper:implScrollToCell(percent, duration)
    local dir = self:getDirection()
    if dir == ccui.ScrollViewDir.vertical then
        self:scrollToPercentVertical(percent, duration, false)
    elseif dir == ccui.ScrollViewDir.horizontal then
        self:scrollToPercentHorizontal(percent, duration, false)
    end
end

function ListViewHelper:backToOriginPos()
    local dir = self:getDirection()
    if dir == ccui.ScrollViewDir.vertical then
        self:scrollToTop(0.01, false)
        print("list view jump to top")
    elseif dir == ccui.ScrollViewDir.horizontal then
        self:scrollToLeft(0.01, false)
        print("list view jump to left")
    end
end

-- 更新列表
function ListViewHelper:updateItems()
    local pos = cc.p(self:getInnerContainer():getPosition())
    local dir = self:getDirection()
    if dir == ccui.ScrollViewDir.vertical then
        self:loadVertical(pos.y)
    elseif dir == ccui.ScrollViewDir.horizontal then
        self:loadHorizontal(pos.x)
    end
end

-- 填充垂直方向
function ListViewHelper:loadVertical(yOffset)
    local index = 0
    if yOffset < 0 then
        index = math.floor(-yOffset / (self.cell_size.height + self.items_margin))
    end
    local total = self.total
    index = total - index
    local count = math.floor(self:getContentSize().height / self.cell_size.height)
    index = index - count
    if index < 1 then
        index = 1
    end
    --count = count
    -- 默认填充1屏
    for i = -1, count do
        local idx = index + i - 1
        local node = self:getNode(idx)
        if node then
            if not node.item then
                self:createItem(node, idx)
                --print(idx, index, count)
                if self.interval_load then break end
            elseif node.dirty then
                self:refreshItem(node, idx)
            end
        end
    end
end

-- 填充水平方向
function ListViewHelper:loadHorizontal(xOffset)
    local index = 1
    if xOffset < 0 then
        index = math.ceil(-xOffset / (self.cell_size.width + self.items_margin))
    end
    local count = math.floor(self:getContentSize().width / self.cell_size.width)
    count = count + 2
    --print(xOffset, index)
    -- 默认填充1屏
    for i = -2, count do
        local idx = index + i
        local node = self:getNode(idx)
        if node then
            if not node.item then
                self:createItem(node, idx)
                if self.interval_load then break end
            elseif node.dirty then
                self:refreshItem(node, idx)
            end
        end
    end
end

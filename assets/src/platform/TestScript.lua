local function swap(tb, idx1, idx2)
    local tmp = tb[idx1]
    tb[idx1] = tb[idx2]
    tb[idx2] = tmp
end

local count = 0
local function permutation(tb, length, index, deep)
    if index == length then
        count = count + 1
        print("conut" .. count, unpack(tb))
        return
    end
    for i = index, length do
        if tb[1] == 1 then
            swap(tb, index, i)
            permutation(tb, length, index + 1, deep + 1)
            swap(tb, index, i)
        end
    end

end

local function test1()
    local tb = {1, 2, 3, 4, 5, 6}
    permutation(tb, #tb, 1, 1)
end

test1()

local queen = {}
local array = {1, 2, 3, 4, 5}

local count = 0
local function comb(s, n, m, top)
    if s == n + 1 then return end
    if top == m + 1 then
        count = count + 1
        print("conut", count, unpack(queen))
        return
    end
    --if array[s].used then return end
    queen[top] = array[s].idx
    array[s].used = true
    top = top + 1
    comb(s + 1, n, m, top)
    top = top - 1
    comb(s + 1, n, m, top)
end

local function test()
    local t1 = os.clock()
    local cnt = 13
    array = {}
    for i = 1, cnt do
        local unit = {}
        unit.idx = i
        unit.used = false
        table.insert(array, unit)
    end
    comb(1, cnt, 3, 1)
    print("cost time", os.clock() - t1)
end

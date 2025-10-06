local chapter_count = 0

local function ensure_table(value)
    if type(value) == "table" then
        return value
    end
    return {}
end

-- デバッグ用の関数
local function debug_print(msg)
    -- Pandocの標準エラー出力にデバッグ情報を出力
    io.stderr:write("[DEBUG] " .. tostring(msg) .. "\n")
    io.stderr:flush()
end

function Header(el)
    debug_print("Processing header: level=" .. tostring(el.level) .. ", content=" .. pandoc.utils.stringify(el.content))
    
    if el.level ~= 1 then
        return el
    end

    chapter_count = chapter_count + 1
    debug_print("Chapter count: " .. tostring(chapter_count))

    -- mark the header as unnumbered so pandoc does not prepend its own numerals
    el.attributes = ensure_table(el.attributes)
    el.classes = ensure_table(el.classes)

    if not el.attributes.unnumbered then
        el.attributes.unnumbered = "true"
    end

    local has_class = false
    for _, class in ipairs(el.classes) do
        if class == "unnumbered" then
            has_class = true
            break
        end
    end
    if not has_class then
        table.insert(el.classes, "unnumbered")
    end

    -- 章番号を追加（より確実な方法）
    local prefix = pandoc.Str("第" .. tostring(chapter_count) .. "章")
    
    -- 既存のコンテンツを保持して、先頭に章番号を追加
    local new_content = pandoc.List()
    new_content:insert(prefix)
    new_content:insert(pandoc.Space())
    
    -- 既存のコンテンツを追加
    for i, item in ipairs(el.content) do
        new_content:insert(item)
    end
    
    el.content = new_content
    
    debug_print("Final content: " .. pandoc.utils.stringify(el.content))

    return el
end
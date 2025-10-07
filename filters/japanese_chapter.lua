local chapter_count = 0
local section_count = 0
local current_chapter = 0

local function ensure_table(value)
    if type(value) == "table" then
        return value
    end
    return {}
end

function Header(el)
    if el.level == 1 then
        -- 第1レベルのヘッダー（章）の処理
        section_count = 0  -- 新しい章が始まるのでセクションカウントをリセット

    -- 除外する章の条件をチェック
    local exclude_patterns = {
        "目次",
        "内容梗概", 
        "謝辞",
        "参考文献",
        "付録",
        "ListofFigures",
        "ListofTables", 
        "ListofListings"
    }
    
    -- ヘッダーのテキストを取得
    local header_text = ""
    for _, inline in ipairs(el.content) do
        if inline.t == "Str" then
            header_text = header_text .. inline.text
        end
    end
    
    -- 除外パターンにマッチするかチェック
    local should_exclude = false
    for _, pattern in ipairs(exclude_patterns) do
        if header_text:find(pattern) then
            should_exclude = true
            break
        end
    end
    
    -- {-}クラスが付いている場合は除外
    el.classes = ensure_table(el.classes)
    for _, class in ipairs(el.classes) do
        if class == "{-}" then
            should_exclude = true
            break
        end
    end
    
    -- 除外対象でない場合のみ章番号を付ける
    if not should_exclude then
        chapter_count = chapter_count + 1

        -- mark the header as unnumbered so pandoc does not prepend its own numerals
        el.attributes = ensure_table(el.attributes)

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

        local prefix = pandoc.Str("第" .. tostring(chapter_count) .. "章")
        current_chapter = chapter_count

        el.content:insert(1, pandoc.Space())
        el.content:insert(1, prefix)
        
        -- デバッグ用の出力（実際の動作確認用）
        print("章番号付与: " .. tostring(chapter_count) .. " - " .. header_text)
    else
        -- デバッグ用の出力（実際の動作確認用）
        print("除外: " .. header_text)
    end
    
    elseif el.level == 2 then
        -- 第2レベルのヘッダー（セクション）の処理
        if current_chapter > 0 then
            section_count = section_count + 1
            
            -- mark the header as unnumbered so pandoc does not prepend its own numerals
            el.attributes = ensure_table(el.attributes)
            
            if not el.attributes.unnumbered then
                el.attributes.unnumbered = "true"
            end
            
            el.classes = ensure_table(el.classes)
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
            
            local prefix = pandoc.Str(tostring(current_chapter) .. "." .. tostring(section_count))
            
            el.content:insert(1, pandoc.Space())
            el.content:insert(1, prefix)
            
            -- デバッグ用の出力
            local header_text = ""
            for _, inline in ipairs(el.content) do
                if inline.t == "Str" then
                    header_text = header_text .. inline.text
                end
            end
            print("セクション番号付与: " .. tostring(current_chapter) .. "." .. tostring(section_count) .. " - " .. header_text)
        end
    end

    return el
end

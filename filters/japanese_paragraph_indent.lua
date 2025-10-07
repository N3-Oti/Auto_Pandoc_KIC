-- 日本語段落の行頭スペース自動挿入フィルター
-- 見出しの直後の段落に全角スペースを自動挿入する

print("日本語段落インデントフィルターが開始されました")

-- 前の要素がヘッダーかどうかを追跡する
local previous_element_was_header = false
local header_level = 0

function Header(el)
    -- ヘッダーを検出したら、次の段落でインデントを適用する準備
    previous_element_was_header = true
    header_level = el.level
    
    print("ヘッダー検出: レベル" .. header_level .. " - " .. pandoc.utils.stringify(el))
    
    return el
end

function Para(el)
    -- 前の要素がヘッダーで、かつ段落の最初の文字が全角スペースでない場合
    if previous_element_was_header then
        local first_inline = el.content[1]
        
        -- 段落の最初の要素をチェック
        if first_inline and first_inline.t == "Str" then
            local text = first_inline.text
            
            -- 既に全角スペースで始まっていない場合のみ追加
            if not text:match("^　") then
                -- 全角スペースを先頭に追加
                local new_text = "　" .. text
                el.content[1] = pandoc.Str(new_text)
                
                print("段落インデント追加: " .. text:sub(1, 20) .. "... → " .. new_text:sub(1, 21) .. "...")
            else
                print("段落は既にインデント済み: " .. text:sub(1, 20) .. "...")
            end
        elseif first_inline and first_inline.t == "Space" then
            -- スペース要素の場合は、その前に全角スペースを挿入
            table.insert(el.content, 1, pandoc.Str("　"))
            print("スペース要素の前にインデント追加")
        else
            -- その他の場合は段落の最初に全角スペースを挿入
            table.insert(el.content, 1, pandoc.Str("　"))
            print("段落の最初にインデント追加")
        end
        
        -- フラグをリセット
        previous_element_was_header = false
    end
    
    return el
end

-- その他の要素（リスト、引用など）が来たらヘッダーフラグをリセット
function BulletList(el)
    previous_element_was_header = false
    return el
end

function OrderedList(el)
    previous_element_was_header = false
    return el
end

function BlockQuote(el)
    previous_element_was_header = false
    return el
end

function Div(el)
    previous_element_was_header = false
    return el
end

function HorizontalRule(el)
    previous_element_was_header = false
    return el
end

print("日本語段落インデントフィルターの設定完了")

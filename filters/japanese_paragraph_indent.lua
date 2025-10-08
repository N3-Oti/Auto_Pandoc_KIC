-- 日本語段落の行頭スペース自動挿入フィルター
-- 見出しの直後の段落に全角スペースを自動挿入する
-- 改行を保持しつつ、適切にインデントを処理する

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
    
    -- 段落内の改行処理を追加
    local new_content = {}
    local i = 1
    while i <= #el.content do
        local inline = el.content[i]
        
        if inline.t == "SoftBreak" then
            -- ソフト改行を保持し、次の行の先頭に全角スペースを追加
            table.insert(new_content, inline)
            -- 次の要素が文字列の場合、全角スペースを追加
            if i + 1 <= #el.content and el.content[i + 1].t == "Str" then
                local next_text = el.content[i + 1].text
                if not next_text:match("^　") then
                    el.content[i + 1] = pandoc.Str("　" .. next_text)
                end
            end
        elseif inline.t == "LineBreak" then
            -- ハード改行を保持し、次の行の先頭に全角スペースを追加
            table.insert(new_content, inline)
            -- 次の要素が文字列の場合、全角スペースを追加
            if i + 1 <= #el.content and el.content[i + 1].t == "Str" then
                local next_text = el.content[i + 1].text
                if not next_text:match("^　") then
                    el.content[i + 1] = pandoc.Str("　" .. next_text)
                end
            end
        else
            table.insert(new_content, inline)
        end
        
        i = i + 1
    end
    
    el.content = new_content
    return el
end

-- 改行を保持するためのSoftBreak処理
function SoftBreak(el)
    -- ソフト改行を保持（改行を消さない）
    return el
end

-- ハード改行を保持するためのLineBreak処理
function LineBreak(el)
    -- ハード改行を保持（改行を消さない）
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

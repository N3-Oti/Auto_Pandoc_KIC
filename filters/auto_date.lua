-- 自動日付フィルター
-- メタデータのdateが設定されていない場合、今日の日付を自動設定

function Meta(m)
  if m.date == nil then
    -- 今日の日付を日本語形式で取得
    local today = os.date("%Y年%m月%d日")
    m.date = today
    print("📅 自動で日付を設定しました: " .. today)
  else
    print("📅 既存の日付を使用: " .. tostring(m.date))
  end
  return m
end

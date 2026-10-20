param([string]$out)

Set-Content -Path $out -Value ""
function Log($title, $text) {
  "=== $title ===" | Out-File -Append -Encoding utf8 $out
  $text | Out-File -Append -Encoding utf8 $out
}

$base = "http://localhost:3000"

$created = curl.exe -s -i -X POST "$base/orders" -H "content-type: application/json" --data "@body.json"
Log "1. POST /orders" $created
$id = ([regex]::Match(($created -join "`n"), '"id":"(ord-[^"]+)"')).Groups[1].Value

Log "2. GET /orders"        (curl.exe -s -i "$base/orders")
Log "3. GET /orders/:id"    (curl.exe -s -i "$base/orders/$id")
Log "4. DELETE /orders/:id" (curl.exe -s -i -X DELETE "$base/orders/$id")
Log "5. GET deleted order"  (curl.exe -s -i "$base/orders/$id")
Log "6. GET unknown id"     (curl.exe -s -i "$base/orders/nope")
Log "7. GET unknown route"  (curl.exe -s -i "$base/unknown")
Log "8. POST bad JSON"      (curl.exe -s -i -X POST "$base/orders" -H "content-type: application/json" --data "@bad.json")
Log "9. POST empty data"    (curl.exe -s -i -X POST "$base/orders" -H "content-type: application/json" --data "@empty.json")
Log "10. GET /health"       (curl.exe -s -i "$base/health")
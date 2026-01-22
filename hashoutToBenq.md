```mermaid
sequenceDiagram
    autonumber
    participant Vendor as Hashout
    participant System as BenQ AI translation

    Note over Vendor: 0. 呼叫 API 取得選單資料：<br/>- Custom Site Tone<br/>- Source / Target Languages<br/>- Site
    Note over Vendor: 1. 收集翻譯內容，產生出 dataToTranslate.json<br/>(Schema 詳見文件下方 [附錄 A])

    %% 優化點：將路徑與 Payload 分離，閱讀更清晰
    Vendor->>System: 2. POST /services/um-translation
    activate System
    
    %% 優化點：使用 Note 條列參數，不影響時序圖寬度
    Note right of Vendor: **Request Body:**<br/>- dataToTranslate.json Path<br/>- Submission Name<br/>- Custom Site Tone<br/>- Source/Target Languages<br/>- Site / Enable Glossary / Enable Additional Prompt<br/>- callbackUrl

    Note right of System: 3. 驗證參數，建立 Submission<br/>4. 讀取 dataToTranslate.json 並寫入<br/>5. 啟動翻譯
    
    System-->>Vendor: 6. 建立成功 (回傳 submissionId)
    deactivate System

    rect rgb(240, 248, 255)
        Note right of System: **非同步處理開始**
        System->>System: 7. 執行 AI 翻譯 (Process)
        System->>System: 8. 寫入 translated.json
        
        %% 這裡 callback 也可以註明帶什麼參數回去，通常對開發很有幫助
        System->>Vendor: 9. POST {callbackUrl}
        Note left of System: Payload: { submissionId, status }
    end
    
    activate Vendor
    Note over Vendor: 10. 接收 callback，取得翻譯狀態
    Vendor->>System: 11. 讀取 translated.json<br/>(by node path /apps/ai-translator/submissions/{submissionId}/translated.json)
    System-->>Vendor: 取得翻譯結果 JSON
    Note over Vendor: 12. 將結果寫入UM
    deactivate Vendor
```
### 附錄 A：dataToTranslate.json 資料格式說明

此 JSON 檔案為翻譯請求的核心 Payload，負責定義需要翻譯的內容區塊及其屬性。

- **格式**：JSON Object
- **層級說明**：
    - **Key (第一層)**：內容節點路徑 (Content Node Path)。這通常是 AEM Content的絕對路徑，作為該內容區塊的唯一識別碼 (Unique Identifier)。
    - **Value (第一層)**：該節點下需要翻譯的屬性物件 (Property Object)。
    - **Key (第二層)**：Property name (如 `title`, `description`, `text`, `button`)。
    - **Value (第二層)**：待翻譯的原始字串。

#### ⚠️ 注意事項
1.  **HTML 標籤**：欄位內容可能包含 HTML 標籤（如 `<a>`, `<span>`, `<p>`）。翻譯系統會保留這些標籤結構，僅翻譯文字內容。
2.  **特殊字元**：內容包含換行符號 `\n`、`\r` 或引號，需符合標準 JSON 跳脫字元規範。

#### JSON 範例 (Example Payload)

```json
{
  "/content/newb2b/id-id/projector/lh750/jcr:content/root/responsivegrid/contentcontainer_203/containerPar/text_copy_copy": {
    "text": "<p style=\"text-align: center;\"><u><span class=\"text-18\"><a href=\"[https://www.benq.com/en-us/business/resource/trends/understand-hk-effect-and-perceived-brightness.html](https://www.benq.com/en-us/business/resource/trends/understand-hk-effect-and-perceived-brightness.html)\" target=\"_blank\">What is the H-K Effect?</a></span></u></p>\n"
  },
  "/content/b2c/demo/monitor/gaming/ex2710r/jcr:content/root/responsivegrid/g6_text_copy_copy": {
    "button": "Learn How",
    "description": "Everything you need for superb sound reproduction is contained in this monitor. The built-in speakers and the five immersive sound modes designed just for gamers delivers a surround sound experience. Plug it in, turn it on and listen, nothing more to do. It’s a much higher-quality alternative to headphones and avoids the hassle of having to connect external speakers.\r\n\r\n",
    "title": "Enchanting Sound Performance With Nothing to Plug In"
  },
  "/content/b2c/demo/monitor/gaming/ex2710r/jcr:content/root/responsivegrid/g6_item_list_5175745/equalWidthItems/item1": {
    "description": "1440p / 16:9 / 120Hz",
    "title": "Xbox Series S"
  },
  "/content/b2c/demo/monitor/gaming/ex2710r/jcr:content/root/responsivegrid/g6_item_list_308435975/equalWidthItems/item1": {
    "description": "-5˚ ~ 15˚",
    "title": "Tilt"
  },
  "/content/b2c/demo/monitor/gaming/ex2710r/jcr:content/root/responsivegrid/g6_item_list_1585659655/equalWidthItems/item1": {
    "description": "Flicker-Free™ eliminates screen flicker during extended viewing. TÜV Rheinland has certified the EX2710R Flicker-free™.",
    "title": "Flicker-Free™"
  }
}
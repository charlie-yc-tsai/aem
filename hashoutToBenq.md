### Integration Workflow

```mermaid
sequenceDiagram
    autonumber
    participant Vendor as Hashout
    participant System as BenQ AI translation

    Note over Vendor: 0. Call API to retrieve menu options:<br/>- Custom Site Tone<br/>- Source / Target Languages<br/>- Site
    Note over Vendor: 1. Collect translation content and generate dataToTranslate.json<br/>(See Appendix A below for Schema details)

    %% Optimization: Separate path and Payload for better readability
    Vendor->>System: 2. POST /services/um-translation
    activate System
    
    %% Optimization: Use Note to list parameters to avoid widening the sequence diagram
    Note right of Vendor: **Request Body:**<br/>- dataToTranslate.json Path<br/>- Submission Name<br/>- Custom Site Tone<br/>- Source/Target Languages<br/>- Site / Enable Glossary / Enable Additional Prompt<br/>- callbackUrl

    Note right of System: 3. Validate parameters, create Submission<br/>4. Read dataToTranslate.json and write to storage<br/>5. Start translation
    
    System-->>Vendor: 6. Creation successful (returns submissionId)
    deactivate System

    rect rgb(240, 248, 255)
        Note right of System: **Async Processing Starts**
        System->>System: 7. Execute AI Translation (Process)
        System->>System: 8. Write translated.json
        
        %% Comment: Specifying callback parameters here helps development
        System->>Vendor: 9. POST {callbackUrl}
        Note left of System: Payload: { submissionId, status }
    end
    
    activate Vendor
    Note over Vendor: 10. Receive callback, get translation status
    Vendor->>System: 11. Read translated.json<br/>(by node path /apps/ai-translator/submissions/{submissionId}/translated.json)
    System-->>Vendor: Retrieve translation result JSON
    Note over Vendor: 12. Write results to UM
    deactivate Vendor

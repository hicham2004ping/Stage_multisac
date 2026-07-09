BEGIN TRY

BEGIN TRAN;

-- CreateTable
CREATE TABLE [dbo].[Role] (
    [id] INT NOT NULL IDENTITY(1,1),
    [nom] NVARCHAR(1000) NOT NULL,
    CONSTRAINT [Role_pkey] PRIMARY KEY CLUSTERED ([id])
);

-- CreateTable
CREATE TABLE [dbo].[User] (
    [id] INT NOT NULL IDENTITY(1,1),
    [nom] NVARCHAR(1000) NOT NULL,
    [prenom] NVARCHAR(1000) NOT NULL,
    [email] NVARCHAR(1000) NOT NULL,
    [service] NVARCHAR(1000) NOT NULL,
    [site] NVARCHAR(1000) NOT NULL,
    [isActive] BIT NOT NULL CONSTRAINT [User_isActive_df] DEFAULT 1,
    [roleId] INT NOT NULL,
    CONSTRAINT [User_pkey] PRIMARY KEY CLUSTERED ([id]),
    CONSTRAINT [User_email_key] UNIQUE NONCLUSTERED ([email])
);

-- CreateTable
CREATE TABLE [dbo].[AiProvider] (
    [id] INT NOT NULL IDENTITY(1,1),
    [nom] NVARCHAR(1000) NOT NULL,
    [modelName] NVARCHAR(1000) NOT NULL,
    [enabled] BIT NOT NULL CONSTRAINT [AiProvider_enabled_df] DEFAULT 1,
    [priority] INT NOT NULL,
    [costRules] FLOAT(53) NOT NULL,
    CONSTRAINT [AiProvider_pkey] PRIMARY KEY CLUSTERED ([id])
);

-- CreateTable
CREATE TABLE [dbo].[TokenUsageLog] (
    [id] INT NOT NULL IDENTITY(1,1),
    [inputTokens] INT NOT NULL,
    [outputTokens] INT NOT NULL,
    [costEstimate] FLOAT(53) NOT NULL,
    [providerId] INT NOT NULL,
    [userId] INT NOT NULL,
    CONSTRAINT [TokenUsageLog_pkey] PRIMARY KEY CLUSTERED ([id])
);

-- CreateTable
CREATE TABLE [dbo].[ChatSession] (
    [id] INT NOT NULL IDENTITY(1,1),
    [title] NVARCHAR(1000),
    [createdAt] DATETIME2 NOT NULL CONSTRAINT [ChatSession_createdAt_df] DEFAULT CURRENT_TIMESTAMP,
    [userId] INT NOT NULL,
    CONSTRAINT [ChatSession_pkey] PRIMARY KEY CLUSTERED ([id])
);

-- CreateTable
CREATE TABLE [dbo].[ChatMessage] (
    [id] INT NOT NULL IDENTITY(1,1),
    [content] NVARCHAR(1000) NOT NULL,
    [createdAt] DATETIME2 NOT NULL CONSTRAINT [ChatMessage_createdAt_df] DEFAULT CURRENT_TIMESTAMP,
    [tokens] INT NOT NULL,
    [providerId] INT NOT NULL,
    [sessionId] INT NOT NULL,
    CONSTRAINT [ChatMessage_pkey] PRIMARY KEY CLUSTERED ([id])
);

-- CreateTable
CREATE TABLE [dbo].[AuditLog] (
    [id] INT NOT NULL IDENTITY(1,1),
    [userId] INT NOT NULL,
    [action] NVARCHAR(1000) NOT NULL,
    [createdAt] DATETIME2 NOT NULL CONSTRAINT [AuditLog_createdAt_df] DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT [AuditLog_pkey] PRIMARY KEY CLUSTERED ([id])
);

-- CreateTable
CREATE TABLE [dbo].[EmailMessage] (
    [id] INT NOT NULL IDENTITY(1,1),
    [fromEmail] NVARCHAR(1000) NOT NULL,
    [content] NVARCHAR(1000) NOT NULL,
    [subject] NVARCHAR(1000) NOT NULL,
    [status] NVARCHAR(1000) NOT NULL,
    [hash] NVARCHAR(1000) NOT NULL,
    [receivedAt] DATETIME2 NOT NULL,
    CONSTRAINT [EmailMessage_pkey] PRIMARY KEY CLUSTERED ([id])
);

-- CreateTable
CREATE TABLE [dbo].[EmailAttachment] (
    [id] INT NOT NULL IDENTITY(1,1),
    [emailId] INT NOT NULL,
    [fileName] NVARCHAR(1000) NOT NULL,
    [mimeType] NVARCHAR(1000) NOT NULL,
    [chemin] NVARCHAR(1000) NOT NULL,
    [size] INT NOT NULL,
    CONSTRAINT [EmailAttachment_pkey] PRIMARY KEY CLUSTERED ([id])
);

-- CreateTable
CREATE TABLE [dbo].[AiAnalysis] (
    [id] INT NOT NULL IDENTITY(1,1),
    [summary] NVARCHAR(1000) NOT NULL,
    [category] NVARCHAR(1000) NOT NULL,
    [priority] NVARCHAR(1000) NOT NULL,
    [confidence] FLOAT(53) NOT NULL,
    [emailId] INT NOT NULL,
    [providerId] INT NOT NULL,
    CONSTRAINT [AiAnalysis_pkey] PRIMARY KEY CLUSTERED ([id])
);

-- CreateTable
CREATE TABLE [dbo].[TicketDraft] (
    [id] INT NOT NULL IDENTITY(1,1),
    [title] NVARCHAR(1000) NOT NULL,
    [status] NVARCHAR(1000) NOT NULL,
    [aiAnalysisId] INT NOT NULL,
    CONSTRAINT [TicketDraft_pkey] PRIMARY KEY CLUSTERED ([id])
);

-- CreateTable
CREATE TABLE [dbo].[MsupportApiLog] (
    [id] INT NOT NULL IDENTITY(1,1),
    [StatusCode] INT NOT NULL,
    [requestJson] NVARCHAR(1000) NOT NULL,
    [createdAt] DATETIME2 NOT NULL CONSTRAINT [MsupportApiLog_createdAt_df] DEFAULT CURRENT_TIMESTAMP,
    [responseJson] NVARCHAR(1000) NOT NULL,
    [ticketId] INT NOT NULL,
    CONSTRAINT [MsupportApiLog_pkey] PRIMARY KEY CLUSTERED ([id])
);

-- AddForeignKey
ALTER TABLE [dbo].[User] ADD CONSTRAINT [User_roleId_fkey] FOREIGN KEY ([roleId]) REFERENCES [dbo].[Role]([id]) ON DELETE NO ACTION ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE [dbo].[TokenUsageLog] ADD CONSTRAINT [TokenUsageLog_providerId_fkey] FOREIGN KEY ([providerId]) REFERENCES [dbo].[AiProvider]([id]) ON DELETE NO ACTION ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE [dbo].[TokenUsageLog] ADD CONSTRAINT [TokenUsageLog_userId_fkey] FOREIGN KEY ([userId]) REFERENCES [dbo].[User]([id]) ON DELETE NO ACTION ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE [dbo].[ChatSession] ADD CONSTRAINT [ChatSession_userId_fkey] FOREIGN KEY ([userId]) REFERENCES [dbo].[User]([id]) ON DELETE NO ACTION ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE [dbo].[ChatMessage] ADD CONSTRAINT [ChatMessage_providerId_fkey] FOREIGN KEY ([providerId]) REFERENCES [dbo].[AiProvider]([id]) ON DELETE NO ACTION ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE [dbo].[ChatMessage] ADD CONSTRAINT [ChatMessage_sessionId_fkey] FOREIGN KEY ([sessionId]) REFERENCES [dbo].[ChatSession]([id]) ON DELETE NO ACTION ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE [dbo].[AuditLog] ADD CONSTRAINT [AuditLog_userId_fkey] FOREIGN KEY ([userId]) REFERENCES [dbo].[User]([id]) ON DELETE NO ACTION ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE [dbo].[EmailAttachment] ADD CONSTRAINT [EmailAttachment_emailId_fkey] FOREIGN KEY ([emailId]) REFERENCES [dbo].[EmailMessage]([id]) ON DELETE NO ACTION ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE [dbo].[AiAnalysis] ADD CONSTRAINT [AiAnalysis_emailId_fkey] FOREIGN KEY ([emailId]) REFERENCES [dbo].[EmailMessage]([id]) ON DELETE NO ACTION ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE [dbo].[AiAnalysis] ADD CONSTRAINT [AiAnalysis_providerId_fkey] FOREIGN KEY ([providerId]) REFERENCES [dbo].[AiProvider]([id]) ON DELETE NO ACTION ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE [dbo].[TicketDraft] ADD CONSTRAINT [TicketDraft_aiAnalysisId_fkey] FOREIGN KEY ([aiAnalysisId]) REFERENCES [dbo].[AiAnalysis]([id]) ON DELETE NO ACTION ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE [dbo].[MsupportApiLog] ADD CONSTRAINT [MsupportApiLog_ticketId_fkey] FOREIGN KEY ([ticketId]) REFERENCES [dbo].[TicketDraft]([id]) ON DELETE NO ACTION ON UPDATE CASCADE;

COMMIT TRAN;

END TRY
BEGIN CATCH

IF @@TRANCOUNT > 0
BEGIN
    ROLLBACK TRAN;
END;
THROW

END CATCH

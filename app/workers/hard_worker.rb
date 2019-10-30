class HardWorker
    include Sidekiq::Worker
    sidekiq_options retry: false
    
    def perform(content)
        message = Message.new(body: content)
        if message.save
            socket = { message: message.body, type: 'message' }
            ActionCable.server.broadcast('chat:chat_channel', socket)
        end
    end
end
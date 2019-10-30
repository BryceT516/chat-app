class RepeatWorker
    include Sidekiq::Worker
    sidekiq_options retry: false

    def perform(count)
        statement = "Repeater: Statement #{count}"
        message = Message.new(body: statement)
        if message.save
            socket = { message: statement, type: 'message' }
            ActionCable.server.broadcast('chat:chat_channel', socket)
        end
        if count > 0
            RepeatWorker.perform_in(count.seconds, count - 1)
        end
    end
end
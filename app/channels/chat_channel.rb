class ChatChannel < ApplicationCable::Channel
  def subscribed
    stream_for 'chat_channel'
    messages = Message.all.collect(&:body)
    if messages
      socket = { messages: messages, type: 'messages' }
      ChatChannel.broadcast_to('chat_channel', socket)
    end
  end
  
  def speak(data)
    message = Message.new(body: data['message'])
    if message.save
      socket = { message: message.body, type: 'message' }
      ChatChannel.broadcast_to('chat_channel', socket)
    end
  end

  def load
    messages = Message.all.collect(&:body)
    socket = { messages: messages, type: 'messages' }
    ChatChannel.broadcast_to('chat_channel', socket)
  end
  
  def queue_it
    HardWorker.perform_async('Queued message sent now.')
    HardWorker.perform_in(30.seconds, 'Message Queued for 30 seconds later.')
    RepeatWorker.perform_async(10)
  end
  
  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end

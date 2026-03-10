# app/controllers/messages_controller.rb
class MessagesController < ApplicationController
  def create
    @adventure = Adventure.find(params[:adventure_id])
    @adventure.messages.create!(role: "user", content: message_params[:content])

    chat = RubyLLM.chat
    chat.with_instructions(dungeon_master_prompt(@adventure))

    history_text = @adventure.messages.order(:created_at).map do |m|
      "#{m.role.capitalize}: #{m.content}"
    end.join("\n\n")

    response = chat.ask(history_text)
    ai_reply = response.content
    @adventure.messages.create!(role: "assistant", content: ai_reply)

    redirect_to adventure_path(@adventure)
  end

  private

  def message_params
    params.require(:message).permit(:content)
  end

  def dungeon_master_prompt(adventure)
    "You are a Dungeon Master running a D&D adventure.
     The player's character is #{adventure.character_name}, a #{adventure.character_class}.
     Narrate vividly in second person. End each response with 2-3 numbered choices for the player."
  end
end

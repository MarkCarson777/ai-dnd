# app/controllers/adventures_controller.rb
class AdventuresController < ApplicationController
  def index
    @adventures = current_user.adventures.order(created_at: :desc)
  end

  def new
    @adventure = Adventure.new
  end

  def create
    @adventure = Adventure.new(adventure_params)
    @adventure.user = current_user
    if @adventure.save
      opening = "Begin my adventure as #{@adventure.character_name}, a #{@adventure.character_class}."
      @adventure.messages.create!(role: "user", content: opening)
      ai_reply = call_openai(@adventure)
      @adventure.messages.create!(role: "assistant", content: ai_reply)
      redirect_to adventure_path(@adventure)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @adventure = Adventure.find(params[:id])
    @message = Message.new
  end

  private

  def adventure_params
    params.require(:adventure).permit(:character_name, :character_class)
  end

  def call_openai(adventure)
    chat = RubyLLM.chat
    chat.with_instructions(dungeon_master_prompt(adventure))

    history_text = adventure.messages.order(:created_at).map do |m|
      "#{m.role.capitalize}: #{m.content}"
    end.join("\n\n")

    response = chat.ask(history_text)
    response.content
  end

  def dungeon_master_prompt(adventure)
    "You are a Dungeon Master running a D&D adventure.
     The player's character is #{adventure.character_name}, a #{adventure.character_class}.
     Narrate vividly in second person. End each response with 2-3 numbered choices for the player."
  end
end

module UsersHelper
  def reputation_color(user)
    score = user.reputation
    red = 255
    green = 255
    
    if score > 255
      red -= (score - 255)
    elsif score < 255
      green -= (255 - score)
    end
    
    "rgb(#{red}, #{green}, 0)"
  end
end

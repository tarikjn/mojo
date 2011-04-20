module StepflowHelper
  
  # static instance variable
  @@nav_captions = {
    :steps => [
      'Create or Join?',
      'Activity Details', # 'Create Activity' when in create mode?
      'Profile Information',
      'Finish :)'
    ],
    :remaining => {
      'discover' => '2 more minutes',
      'create'   => '1 more minute',
      'join'     => '1 more minute',
      'profile'  => '30 more seconds',
      'review'   => '5 more seconds'
    }
  }
  
  def nav_captions
    @@nav_captions
  end
  
end

class QuickTabsWidget < Widget
  field :settings, :type => Hash, :default => {'style' => 'margin-top: 42px'}
  
  def style
    settings['style']
  end
end

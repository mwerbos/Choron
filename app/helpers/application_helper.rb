module ApplicationHelper
  def bid_sorter(a,b)
    return 2*(a.total <=> b.total)+(a.created_at <=> b.created_at)
  end
  def current_tab_id(controller, action_name)
    return 'current' if controller.class == controller and controller.action_name == action_name
    return ''
  end
end

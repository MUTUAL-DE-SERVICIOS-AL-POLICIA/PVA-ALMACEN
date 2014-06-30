class UsersDatatable
  delegate :current_user, :params, :link_to_if, :links_actions, :type_status, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: User.count,
      iTotalDisplayRecords: array.total_entries,
      aaData: current_user.is_super_admin? ? data_admin : data
    }
  end

private

  def data_admin
    array.map do |user|
      [
        user.name,
        I18n.t(user.role, scope: 'users.roles'),
        type_status(user.status),
        (links_actions(user) unless user.role == 'super_admin')
      ]
    end
  end

  def data
    array.map do |user|
      [
        user.code,
        user.name,
        user.title,
        link_to_if(user.department, user.department_name, user.department, title: user.department_code),
        type_status(user.status),
        links_actions(user)
      ]
    end
  end

  def array
    @users ||= fetch_array
  end

  def fetch_array
    User.array_model(sort_column, sort_direction, page, per_page, params[:sSearch], params[:search_column], current_user)
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i < 0 ? User.count + 1 : params[:iDisplayLength].to_i
  end

  def sort_column
    columns = current_user.is_super_admin? ? %w[users.name role users.status] : %w[users.code users.name title departments.name users.status]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end

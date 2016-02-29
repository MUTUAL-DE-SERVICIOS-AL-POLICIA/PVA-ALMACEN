class NoteEntriesDatatable
  delegate :params, :dom_id, :link_to, :links_actions, :content_tag, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: NoteEntry.count,
      iTotalDisplayRecords: array.total_entries,
      aaData: data
    }
  end

private

  def data
    array.map do |r|
      [
        I18n.l(r.note_entry_date),
        r.nro_nota_ingreso,
        r.supplier_name,
        r.user_name,
        r.total,
        r.note_date(r.delivery_note_date),
        [links_actions(r, 'asset'), link_to(content_tag(:span, "", class: 'glyphicon glyphicon-sort-by-order'), '#editar', class: 'btn btn-info btn-xs editar-nota-entrada', title: 'Establecer número de nota de entrada', data: {"nota-entrada" => r.as_json}, id: dom_id(r))].join(' ')
      ]
    end
  end

  def array
    @note_entries ||= fetch_array
  end

  def fetch_array
    NoteEntry.array_model(sort_column, sort_direction, page, per_page, params[:sSearch], params[:search_column])
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i < 0 ? NoteEntry.count + 1 : params[:iDisplayLength].to_i
  end

  def sort_column
    columns = %w[note_entries.note_entry_date note_entries.nro_nota_ingreso suppliers.name users.name note_entries.total note_entries.delivery_note_date]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end

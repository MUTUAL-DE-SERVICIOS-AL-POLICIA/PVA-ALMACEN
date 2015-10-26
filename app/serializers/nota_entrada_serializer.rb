class NotaEntradaSerializer < ActiveModel::Serializer
  attributes :id, :nro, :empresa, :encargado, :fecha, :total, :nota_entrega_nro, :factura_nro, :anulado, :mensaje, :creado_el

  def nro
    ''
  end

  def empresa
    object.supplier_name
  end

  def encargado
    object.user_name
  end

  def fecha
    object.note_entry_date
  end

  def nota_entrega_nro
    object.delivery_note_number
  end

  def factura_nro
    object.invoice_number
  end

  def creado_el
    object.created_at
  end

  def anulado
    object.invalidate
  end

  def mensaje
    object.message
  end
end

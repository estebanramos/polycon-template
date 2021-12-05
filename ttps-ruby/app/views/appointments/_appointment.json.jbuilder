json.extract! appointment, :id, :date, :name, :surname, :phone, :notes, :professional_id, :created_at, :updated_at
json.url appointment_url(appointment, format: :json)

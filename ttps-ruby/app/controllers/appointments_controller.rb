class AppointmentsController < ApplicationController
  before_action :set_appointment, only: %i[ show edit update destroy ]
  before_action :authenticate_user!
  load_and_authorize_resource


  # GET /appointments or /appointments.json
  def index
    @appointments = Appointment.all
  end

  # GET /appointments/1 or /appointments/1.json
  def show
  end

  # GET /appointments/new
  def new
    @appointment = Appointment.new
  end

  # GET /appointments/1/edit
  def edit
  end

  # POST /appointments or /appointments.json
  def create
    authorize! :manage, @appointment
    @appointment = Appointment.new(appointment_params)

    respond_to do |format|
      if @appointment.save
        format.html { redirect_to @appointment, notice: "Appointment was successfully created." }
        format.json { render :show, status: :created, location: @appointment }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @appointment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /appointments/1 or /appointments/1.json
  def update
    authorize! :manage, @appointment
    respond_to do |format|
      if @appointment.update(appointment_params)
        format.html { redirect_to @appointment, notice: "Appointment was successfully updated." }
        format.json { render :show, status: :ok, location: @appointment }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @appointment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /appointments/1 or /appointments/1.json
  def destroy
    @appointment.destroy
    respond_to do |format|
      format.html { redirect_to appointments_url, notice: "Appointment was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def export
    render :export
  end

  def download_file
    date = params["date"]
    professional = params["professional"]
    if params["week"] == "0"
      week = false
    else
      week = true
    end
    puts "WEEK VALUE: #{week}"
    puts date, professional, week
    if week
      weekday_index = Date::DAYNAMES.reverse.index("Monday")
      days_before = (Time.parse(date).wday + weekday_index) % 7 + 1
      start_of_week = Time.parse(date).to_date - days_before
    end

    appointments_list = []
    if professional
      appointments = Appointment.where(professional: professional)
      appointments.each do |a|
        if week && (start_of_week..start_of_week+7).cover?(a[:date])
          appointments_list.push(a)
        elsif a.date.day == Time.parse(date).day and a.date.month == Time.parse(date).month
            appointments_list.append(a)
        end
      end
    else
      appointments = Appointment.all
      appointments.each do |a|
        if week && (start_of_week..start_of_week+7).cover?(a[:date])
          appointments_list.push(a)
        elsif a.date.day == Time.parse(date).day and a.date.month == Time.parse(date).month
          appointments_list.append(a)
        end
      end
    end

    hour_list = ["9:00", "9:15", "9:30", "9:45","10:00", "10:15", "10:30", "10:45", "11:00", "11:15", "11:30", "11:45", "12:00"]
    for_template = []
    a_list = []
    hour_list.each do |h|
      a_list = []
      appointments_list.each do |a|
        real_time = Time.parse(h)
        appointment_hour = a.date.hour
        appointment_minute = a.date.min
        if real_time.hour == appointment_hour && (appointment_minute <= real_time.min+15 && appointment_minute >= real_time.min)
          element = {:date => a.date, :pacient_name => a.name+' '+a.surname, :professional_name => a.professional.name}
          a_list.push(element)
        end
      end
      hash = {:hour => h, :a_list => a_list}
      for_template.push(hash)
    end
    template = ERB.new <<-EOF
    <% if week %> Appointments for week  <%= start_of_week %>  <% else %> Appointments for date <%= date %> <% end %>
    Date           Appointment        Professional
    <% for_template.each do |val| %>
    
    <%= val[:hour]%>        <% if val[:a_list].length > 0 %> <% val[:a_list].each do |val1| %>  <%= val1[:pacient_name]%>(<% if week %><%= val1[:date] %><% end %>) <% if val1[:professional_name]%>      <%= val1[:professional_name] %><% end %><% end %><% else %>   SIN TURNO                                                 
        <% end %>
        <% end %>          
    EOF
              File.open("#{date}-export", 'w') do |f|
                f.write template.result(binding)
              end
              File.open("#{date}-export", 'r') do |f|
                send_data f.read, :filename => "#{date}-export.html"
              end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_appointment
      @appointment = Appointment.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def appointment_params
      params.require(:appointment).permit(:date, :name, :surname, :phone, :notes, :professional_id)
    end
end



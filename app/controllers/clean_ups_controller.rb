class CleanUpsController < ApplicationController
  def calendar
    @clean_up = CleanUp.find(params[:id])

    ical = generate_icalendar(@clean_up)

    send_data ical,
              type: "text/calendar",
              disposition: "attachment",
              filename: "#{@clean_up.name.parameterize}.ics"
  end

  private

  def generate_icalendar(clean_up)
    start_time = clean_up.starts_at.strftime("%Y%m%dT%H%M%SZ")
    end_time = (clean_up.starts_at + 2.hours).strftime("%Y%m%dT%H%M%SZ")
    timestamp = Time.now.strftime("%Y%m%dT%H%M%SZ")
    uid = "#{clean_up.id}-#{clean_up.created_at.to_i}@trashcan-dresden"

    <<~ICAL
      BEGIN:VCALENDAR
      VERSION:2.0
      PRODID:-//Trashcan Dresden//Clean-Up Event//DE
      CALSCALE:GREGORIAN
      METHOD:PUBLISH
      BEGIN:VEVENT
      UID:#{uid}
      DTSTAMP:#{timestamp}
      DTSTART:#{start_time}
      DTEND:#{end_time}
      SUMMARY:#{escape_ical_text(clean_up.name)}
      DESCRIPTION:#{escape_ical_text(clean_up.description.to_s)}
      LOCATION:#{escape_ical_text(clean_up.address.to_s)}
      END:VEVENT
      END:VCALENDAR
    ICAL
  end

  def escape_ical_text(text)
    result = text.dup
    result.gsub!("\\") { "\\\\" }
    result.gsub!(",") { "\\," }
    result.gsub!(";") { "\\;" }
    result.gsub!("\r") { "\\r" }
    result.gsub!("\n") { "\\n" }
    result
  end
end

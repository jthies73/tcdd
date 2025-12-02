class CleanUpsController < ApplicationController
  include Rails.application.routes.url_helpers

  def calendar
    @clean_up = CleanUp.find(params[:id])
    @participation = Participation.find_by(id: params[:participation_id]) if params[:participation_id].present?

    ical = generate_icalendar(@clean_up, @participation)

    send_data ical,
              type: "text/calendar",
              disposition: "attachment",
              filename: "#{@clean_up.name.parameterize}.ics"
  end

  private

  def generate_icalendar(clean_up, participation = nil)
    start_time = clean_up.starts_at.strftime("%Y%m%dT%H%M%SZ")
    end_time = (clean_up.starts_at + 2.hours).strftime("%Y%m%dT%H%M%SZ")
    timestamp = Time.now.strftime("%Y%m%dT%H%M%SZ")
    uid = "#{clean_up.id}-#{clean_up.created_at.to_i}@trashcan-dresden"

    description = build_calendar_description(clean_up, participation)

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
      DESCRIPTION:#{escape_ical_text(description)}
      LOCATION:#{escape_ical_text(clean_up.address.to_s)}
      END:VEVENT
      END:VCALENDAR
    ICAL
  end

  def build_calendar_description(clean_up, participation)
    parts = []
    parts << clean_up.description.to_s if clean_up.description.present?
    parts << "Dein Teilnahme-Link: #{show_participation_url(participation)}" if participation
    parts.join("\n\n")
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

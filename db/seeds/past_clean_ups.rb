# db/seeds/clean_up_history.rb or run directly in rails console

clean_ups_data = [
  { id: 1, name: "Waldstücke Hammerweg 2.0", participants: 53, cigarettes: 0, date: "2025-03-02" },
  { id: 2, name: "Ikarusweg (Klotzsche)", participants: 54, cigarettes: 0, date: "2025-04-27" },
  { id: 3, name: "Coschütz / Kohlenstraße", participants: 50, cigarettes: 0, date: "2025-09-21" },
  { id: 4, name: "Kiesgrube Leuben", participants: 58, cigarettes: 1731, date: "2025-10-26" },
  { id: 5, name: "Dresden-Laubegast", participants: 56, cigarettes: 703, date: "2025-12-01" },
  { name: "Unser Erster Cleanup", participants: 17, cigarettes: 4100, date: "2023-07-22" },
  { name: "Elbufer zwischen Carolabrücke und Albertbrücke", participants: 11, cigarettes: 3300, date: "2023-08-13" },
  { name: "Elbe", participants: 11, cigarettes: 1632, date: "2023-09-16" },
  { name: "Elbufer", participants: 0, cigarettes: 900, date: "2023-10-15" },
  { name: "Elbe", participants: 15.5, cigarettes: 643, date: "2023-10-29" },
  { name: "Clean Up #6", participants: 0, cigarettes: 1550, date: "2023-11-26" },
  { name: "Elbwiesen", participants: 24, cigarettes: 0, date: "2024-01-07" },
  { name: "Clean Up #7", participants: 0, cigarettes: 1132, date: "2024-02-04" },
  { name: "Kaufpark Nickern", participants: 0, cigarettes: 560, date: "2024-02-18" },
  { name: "Zschertnitz", participants: 26, cigarettes: 335, date: "2024-03-17" },
  { name: "Südhöhe", participants: 30, cigarettes: 434, date: "2024-04-07" },
  { name: "Dresden Leuben", participants: 35, cigarettes: 0, date: "2024-04-13" },
  { name: "Dresden Leuben", participants: 14, cigarettes: 0, date: "2024-05-11" },
  { name: "Ostragehege", participants: 30, cigarettes: 12201, date: "2024-05-26" },
  { name: "Elbradweg", participants: 38, cigarettes: 8023, date: "2024-06-23" },
  { name: "Kiesgrube Leuben", participants: 35, cigarettes: 5150, date: "2024-07-14" },
  { name: "Kiesgrube Leuben", participants: 25, cigarettes: 2500, date: "2024-07-21" },
  { name: "Rudolf-Bergander-Ring (Prohlis)", participants: 30, cigarettes: 691, date: "2024-08-18" },
  { name: "Rudolf-Bergander-Ring (Prohlis)", participants: 20, cigarettes: 1112, date: "2024-09-21" },
  { name: "Carolabrücke", participants: 35, cigarettes: 0, date: "2024-10-20" },
  { name: "Ostragehege / Elbufer", participants: 30, cigarettes: 2736, date: "2024-11-10" },
  { name: "Elbwiesen Altstadt", participants: 45, cigarettes: 1630, date: "2025-01-01" },
  { name: "Hellerberge / Lager Kiesgrube", participants: 55, cigarettes: 0, date: "2025-02-02" }
]

ActiveRecord::Base.transaction do
  clean_ups_data.each do |data|
    if data[:id]
      # Find or create record by ID
      clean_up = CleanUp.find_by(id: data[:id])
      if clean_up
        clean_up.update!(
          name: data[:name],
          starts_at: Date.parse(data[:date]),
          manual_cigarettes_count: data[:cigarettes],
          final_participant_count: data[:participants],
          status: "ended"
        )
        puts "Updated CleanUp ##{clean_up.id}: #{clean_up.name} (#{data[:date]})"
      else
        # Create with specific ID if not found
        clean_up = CleanUp.create!(
          id: data[:id],
          name: data[:name],
          starts_at: Date.parse(data[:date]),
          manual_cigarettes_count: data[:cigarettes],
          final_participant_count: data[:participants],
          status: "ended"
        )
        puts "Created CleanUp ##{clean_up.id}: #{clean_up.name} (#{data[:date]})"
      end
    else
      # Create new record
      clean_up = CleanUp.create!(
        name: data[:name],
        starts_at: Date.parse(data[:date]),
        manual_cigarettes_count: data[:cigarettes],
        final_participant_count: data[:participants],
        status: "ended"
      )
      puts "Created CleanUp ##{clean_up.id}: #{clean_up.name} (#{data[:date]})"
    end
  end
end

puts "\nDone! Created/updated #{clean_ups_data.count} clean-up records."
puts "Note: Participant counts (#{clean_ups_data.sum { |d| d[:participants] }} total) need to be added separately via Participation records."
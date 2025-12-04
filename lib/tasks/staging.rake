# frozen_string_literal: true

namespace :staging do
  desc "Seed staging environment with test data"
  task seed: :environment do
    unless Rails.env.staging?
      puts "⚠️  This task should only be run in the staging environment!"
      exit 1
    end

    puts "🌱 Seeding staging environment with test data..."

    # Clean up existing data
    puts "Cleaning up existing data..."
    Participation.destroy_all
    Participant.destroy_all
    CleanUp.destroy_all

    # Create past clean ups
    puts "Creating past clean-ups..."
    5.times do |i|
      start_time = (i + 1).weeks.ago.beginning_of_day + 10.hours
      end_time = start_time + 2.hours
      
      CleanUp.create!(
        start_time: start_time,
        end_time: end_time,
        status: "completed",
        cigarettes_count: rand(100..500),
        manual_cigarettes_count: rand(0..50),
        final_participant_count: rand(5..20)
      )
    end

    # Create an upcoming clean up
    puts "Creating upcoming clean-up..."
    upcoming_start = 1.week.from_now.beginning_of_day + 10.hours
    CleanUp.create!(
      start_time: upcoming_start,
      end_time: upcoming_start + 2.hours,
      status: "scheduled",
      cigarettes_count: 0
    )

    # Create some test participants
    puts "Creating test participants..."
    10.times do
      Participant.create!(
        phone_number: "555-#{rand(1000..9999)}",
        opt_in: true
      )
    end

    # Create some participations
    puts "Creating participations..."
    CleanUp.where(status: "completed").each do |cleanup|
      rand(3..8).times do
        participant = Participant.all.sample
        Participation.create!(
          clean_up: cleanup,
          participant: participant,
          cigarettes_count: rand(10..50)
        )
      end
    end

    puts "✅ Staging data seeded successfully!"
    puts "   - Clean-ups: #{CleanUp.count}"
    puts "   - Participants: #{Participant.count}"
    puts "   - Participations: #{Participation.count}"
  end

  desc "Anonymize production data for staging use"
  task anonymize: :environment do
    unless Rails.env.staging?
      puts "⚠️  This task should only be run in the staging environment!"
      exit 1
    end

    puts "🎭 Anonymizing participant data for staging..."

    Participant.find_each do |participant|
      # Generate fake phone number
      fake_phone = "555-#{rand(1000..9999)}"
      
      participant.update!(
        phone_number: fake_phone
      )
    end

    puts "✅ Data anonymized successfully!"
    puts "   - Participants anonymized: #{Participant.count}"
  end

  desc "Reset staging environment (clean + seed)"
  task reset: :environment do
    unless Rails.env.staging?
      puts "⚠️  This task should only be run in the staging environment!"
      exit 1
    end

    puts "🔄 Resetting staging environment..."
    
    Rake::Task["db:reset"].invoke
    Rake::Task["staging:seed"].invoke
    
    puts "✅ Staging environment reset complete!"
  end
end

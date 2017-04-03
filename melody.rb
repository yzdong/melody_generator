require 'pry'
require 'raingrams'
require 'midilib'

include Raingrams

class Melody 
    PITCHES = %w(C C# D D# E F F# G G# A A# B)
    
    def initialize 
        @notes = []
    end
    
    def to_midi
       seq = MIDI::Sequence.new()
       track = MIDI::Track.new(seq)
       seq.tracks << track
       @notes.each do |note|
           track.events << add_midi(note)
       end
       track.recalc_times
       seq
    end

    def from_midi(seq, channel_num)
        seq.tracks.each do |track| 
            track.each do |event|
                if belongs_to_channel(event, channel_num)
                    add_note_from_midi(event, event.off)
            
                end
            end
        end
    end
    
    def to_str
        str = ''
        @notes.each do |note| 
            str << note[:pitch].to_s + "p" +  note[:duration].to_s + " "  
        end
        str << "."
        str
    end
    
    def from_str(str)
        str.gsub!(/[.]/, "")
        arr = str.split(" ")
        arr.each do |n|
            add_note_from_str(n)
        end
    end
    
    def to_pitches
        str = ''
        @notes.each do |note| 
            str << to_pitch(note[:pitch]) + " "
        end
        str
    end

    private

    def add_note_from_midi(note_on, note_off)
        note = {}
        note[:pitch] = note_on.note
        note[:duration] = note_off.time_from_start - note_on.time_from_start
        @notes << note
    end
   
    def add_note_from_str(str)
        pitch, duration = str.split("p")
        note = {}
        note[:pitch] = pitch
        note[:duration] = duration
        @notes << note
    end

    def add_midi(note) 
        MIDI::NoteOn.new(0, note[:pitch].to_i, 64, note[:duration].to_i) 
    end

    def belongs_to_channel(event, channel_num)
        event.class == MIDI::NoteOn && event.channel == channel_num
    end

    def to_pitch(val) 
        pch = val % 12
        oct = (val / 12) - 1
        "#{PITCHES[pch]}#{oct}"
   end 
end



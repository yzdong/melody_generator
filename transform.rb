require 'pry'
require 'midilib'
require 'raingrams'
require './melody.rb'

include Raingrams

class StrtoMelody

    def self.from_str(str) 
        arr = str.split("p")
        note = {}
        note[:pitch] = arr[0].to_i
        note[:duration] = arr[1].to_i
        return note
    end
    
    def self.from_sentence(sen)
        arr = sen.split(" ")
        m = Melody.new
        arr.each do |note|
            m.add_note(from_str(note))
        end
        m
    end
end 

def read_midi_from_file(path, track_num) 
    m = Melody.new
    seq = MIDI::Sequence.new()
    File.open("inputs/#{path}.mid", "rb") do | file |
        seq.read(file) do | track, num_tracks, i |
            if i + 1 == track_num
                m.from_midi(track)
            end
            puts "read track #{i} from #{path}"
        end
    end
    m.to_str
end

melodies = [{path: "cosi12_uomini", track: 7}, {path: "cosi19_donna", track: 7}, {path: "cosi28_e", track: 9}]

model = HexagramModel.build do |model|
        melodies_str = ''
        melodies.each do |mel|
            melodies_str << read_midi_from_file(mel[:path], mel[:track]) 
        end
        model.train_with_text(melodies_str)
    end

def gen_random_midi(model)
    m = Melody.new 
    m.from_str(model.random_sentence)
    seq=m.to_midi
    File.open('random.mid', 'wb') do |file|
        seq.write(file)
    end
end

gen_random_midi(model)

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
        seq.read(file)
    end
    m.from_midi(seq, track_num)
    m.to_str
end

def create_model(composer)
    mozart_melodies = [{path: "cosi12_uomini", track: 7}, {path: "cosi19_donna", track: 7}, {path: "cosi28_e", track: 9}]

    puccini_melodies = [{path: "boheme2_mi", track: 11}, {path: "boheme3_quando", track: 8}, {path: "boheme4_donde", track: 8}]

    handel_melodies = [{path: "cesare14_vadoro", track: 1}, {path: "rinaldo06_lascia", track: 1}, {path: "agrippina12_coll", track: 3}]

    all_melodies = {}
    all_melodies["mozart"] = mozart_melodies
    all_melodies["puccini"] = puccini_melodies
    all_melodies["handel"] = handel_melodies
    melodies = all_melodies[composer]
    model = HexagramModel.build do |model|
        melodies_str = ''
        melodies.each do |mel|
            melodies_str << read_midi_from_file(mel[:path], mel[:track]) 
        end
        model.train_with_text(melodies_str)
    end
end

def gen_random_midi(model)
    m = Melody.new 
    m.from_str(model.random_sentence)
    seq=m.to_midi
    File.open('random.mid', 'wb') do |file|
        seq.write(file)
    end
end

model = create_model(ARGV[0])
gen_random_midi(model)

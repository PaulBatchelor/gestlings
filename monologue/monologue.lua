Monologue = {}

local function phrase_to_mseq(morpheme, path, phrase, pros, vocab)
    local mseq = {}
    local merge = morpheme.merge

    for _,ph in pairs(phrase) do

        -- duration modifier
        local dur = ph[2] or {1, 1}
        local mrph = vocab[ph[1]]

        -- merge partial morphemes
        if ph[3] ~= nil then
            for _, pm in pairs(ph[3]) do
                mrph = merge(mrph, vocab[pm])
            end
        end

        table.insert(mseq, {mrph, dur})
    end

    local mseq_dur = path.morphseq_dur(mseq)
    -- print(mseq_dur[1], mseq_dur[2])

    -- normalize: condense entire phrase into one beat
    -- for some reason, we don't flip
    -- best I can think of:
    -- rescale each rate multiplier relative to the duration
    -- divide each morpheme rate multiplier by the total duration
    -- duration needs to be converted to rate (flip)
    -- fraction division does an inversion on second operand (flip)
    -- maybe those flips cancel out?
    local scale = mseq_dur
    for idx,_ in pairs(mseq) do
        mseq[idx][2] = path.fracmul(mseq[idx][2], scale)

        -- limited to 8-bit values
        assert(mseq[idx][2][1] <= 0xFF)
        assert(mseq[idx][2][2] <= 0xFF)
    end

    pros_scaled = {}
    pros_scaled.pitch = path.scale_to_morphseq(pros.pitch, mseq)
    pros_scaled.intensity = path.scale_to_morphseq(pros.intensity, mseq)

    return mseq, pros_scaled
end

local function append_to_sequence(app, m, pros_pitch, pros_intensity, mseq, pros)
    for _,mrph in pairs(mseq) do
        local dur = mrph[2]
        local mo = mrph[1]
        app(m, dur, mo)
    end

    for _, v in pairs(pros.pitch) do
        table.insert(pros_pitch, v)
    end

    for _, v in pairs(pros.intensity) do
        table.insert(pros_intensity, v)
    end
end

function Monologue.to_words(p)
    local tal = p.tal
    local path = p.path
    local morpheme = p.morpheme
    local vocab = p.vocab
    local mono = p.monologue
    local lookup = p.shapelut

    local p_shapes = {}
    local pros_pitch = {}
    local pros_intensity = {}
    local app = morpheme.appender(path)
    local m = {} -- TODO rename

    for _,stanza in pairs(mono) do
        mseq, pros = phrase_to_mseq(morpheme, path, stanza[1], stanza[2], vocab, pm)
        append_to_sequence(app, m, pros_pitch, pros_intensity, mseq, pros)
    end

    local words = {}
    tal.begin(words)

    tal.label(words, "hold")
    tal.halt(words)
    tal.jump(words, "hold")

    morpheme.compile_noloop(tal, path, words, m, nil, lookup)

    tal.label(words, "pros_pitch")
    path.path(tal, words, pros_pitch)
    tal.jump(tal, "hold")

    tal.label(words, "pros_intensity")
    path.path(tal, words, pros_intensity)
    tal.jump(tal, "hold")
    return words
end

return Monologue

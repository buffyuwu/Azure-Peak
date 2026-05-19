import {
  Button,
  Dropdown,
  Input,
  LabeledList,
  Section,
  Stack,
  TextArea,
  Slider,
} from 'tgui-core/components';

import { useBackend } from '../../backend';
import type { PreferencesData } from './types';

export function CharacterSetupPage() {
  const { act, data } = useBackend<PreferencesData>();

  return (
    <Stack fill vertical>
      <Stack.Item>
        <Stack fill>
          {/* ── CHARACTER ── */}
          <Stack.Item grow>
            <Section title="Character">
              <div
                style={{
                  display: 'flex',
                  justifyContent: 'center',
                  marginBottom: '8px',
                }}
              >
                <img
                  src={data.headshot_link}
                  style={{
                    width: '162px',
                    height: '162px',
                    borderRadius: '50%',
                    border: '3px solid #424242',
                    boxShadow: '0 0 8px rgba(0,0,0,0.8)',
                    objectFit: 'cover',
                  }}
                />
              </div>
              <hr style={{ borderColor: '#444', margin: '8px 0' }} />
              <LabeledList>
                <LabeledList.Item label="Race">
                  <Button onClick={() => act('set_species')}>
                    {data.species}
                  </Button>
                </LabeledList.Item>
                <LabeledList.Item label="Subrace">
                  <Button onClick={() => act('set_subspecies')}>
                    {data.subspecies}
                  </Button>
                </LabeledList.Item>
                <LabeledList.Item label="Statpack">
                  <Button onClick={() => act('set_statpack')}>
                    {data.statpack}
                  </Button>
                </LabeledList.Item>
                <LabeledList.Item label="Origin">
                  <Button onClick={() => act('set_origin')}>
                    {data.origin}
                  </Button>
                </LabeledList.Item>
                <LabeledList.Item label="Virtue">
                  <Button onClick={() => act('set_virtue')}>
                    {data.virtue}
                  </Button>
                </LabeledList.Item>
                {data.statpack_virtuous && (
                  <LabeledList.Item label="Second Virtue">
                    <Button onClick={() => act('set_virtuetwo')}>
                      {data.virtuetwo}
                    </Button>
                  </LabeledList.Item>
                )}
                <LabeledList.Item label="Vices">
                  <Stack vertical>
                    {(data.charflaws_list || []).map((flaw) => (
                      <Stack.Item key={flaw.index}>
                        <Stack>
                          <Stack.Item grow>{flaw.name}</Stack.Item>
                          <Stack.Item>
                            <Button
                              color="bad"
                              icon="times"
                              tooltip="Remove"
                              onClick={() =>
                                act('remove_charflaw', { index: flaw.index })
                              }
                            />
                          </Stack.Item>
                        </Stack>
                      </Stack.Item>
                    ))}
                    {(data.charflaws_list || []).length < data.max_vices ? (
                      <Stack.Item>
                        <Button onClick={() => act('set_charflaw')}>
                          Add Vice
                        </Button>
                      </Stack.Item>
                    ) : (
                      !(data.charflaws_list || []).length && (
                        <Stack.Item>
                          <span style={{ color: '#888' }}>None</span>
                        </Stack.Item>
                      )
                    )}
                  </Stack>
                </LabeledList.Item>
                {data.has_averse && (
                  <LabeledList.Item label="Loathed Group">
                    <Button onClick={() => act('set_averse_faction')}>
                      {data.averse_faction}
                    </Button>
                  </LabeledList.Item>
                )}
                <LabeledList.Item label="Faith">
                  <Button onClick={() => act('set_faith')}>
                    {data.faith}
                  </Button>
                </LabeledList.Item>
                <LabeledList.Item label="Patron">
                  <Button onClick={() => act('set_patron')}>
                    {data.patron}
                  </Button>
                </LabeledList.Item>
                <LabeledList.Item label="Combat Music">
                  <Button onClick={() => act('set_combat_music')}>
                    {data.combat_music}
                  </Button>
                </LabeledList.Item>
                <LabeledList.Item label="Dominant Hand">
                  <Button
                    onClick={() =>
                      act('set_domhand', { value: data.domhand === 1 ? 2 : 1 })
                    }
                  >
                    {data.domhand === 1 ? 'Left-handed' : 'Right-handed'}
                  </Button>
                </LabeledList.Item>
                <LabeledList.Item label="Unrevivable">
                  <Button
                    selected={data.dnr_pref}
                    onClick={() => act('toggle_dnr')}
                  >
                    {data.dnr_pref ? 'Yes' : 'No'}
                  </Button>
                </LabeledList.Item>
                <LabeledList.Item label="Familiar Prefs">
                  <Button onClick={() => act('open_familiar_prefs')}>
                    Configure
                  </Button>
                </LabeledList.Item>
              </LabeledList>
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <Section title="Identity">
              {data.character_sprite && (
                <div
                  style={{
                    display: 'flex',
                    justifyContent: 'center',
                    marginBottom: '8px',
                  }}
                >
                  <img
                    src={data.character_sprite}
                    style={{
                      width: '162px',
                      height: '162px',
                      imageRendering: 'pixelated',
                      objectFit: 'contain',
                      border: '3px solid #424242',
                      boxShadow: '0 0 8px rgba(0,0,0,0.8)',
                      background: '#1a1a1a',
                    }}
                  />
                </div>
              )}
              {data.character_sprite && (
                <hr style={{ borderColor: '#444', margin: '8px 0' }} />
              )}
              <LabeledList>
                <LabeledList.Item label="Name">
                  <Stack>
                    <Stack.Item grow>
                      <Input
                        fluid
                        value={data.real_name}
                        onEnter={(val) => act('set_name', { value: val })}
                      />
                    </Stack.Item>
                    <Stack.Item>
                      <Button
                        icon="dice"
                        tooltip="Randomize"
                        onClick={() => act('randomize_name')}
                      />
                    </Stack.Item>
                  </Stack>
                </LabeledList.Item>
                <LabeledList.Item label="Nickname">
                  <Input
                    fluid
                    value={data.nickname}
                    onEnter={(val) => act('set_nickname', { value: val })}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Pronouns">
                  <Dropdown
                    options={data.pronouns_options}
                    selected={data.pronouns}
                    onSelected={(val) => act('set_pronouns', { value: val })}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Titles">
                  <Dropdown
                    options={data.titles_options}
                    selected={data.titles_pref}
                    onSelected={(val) => act('set_titles', { value: val })}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Clothing">
                  <Dropdown
                    options={data.clothes_options}
                    selected={data.clothes_pref}
                    onSelected={(val) => act('set_clothes', { value: val })}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Voice Identity">
                  <Dropdown
                    options={data.voice_type_options}
                    selected={data.voice_type}
                    onSelected={(val) => act('set_voice_type', { value: val })}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Voice Pack">
                  <Dropdown
                    options={data.voice_pack_options}
                    selected={data.voice_pack}
                    onSelected={(val) => act('set_voice_pack', { value: val })}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Voice Pitch">
                  <Slider
                    color="bad"
                    minValue={0.8}
                    maxValue={1.35}
                    step={0.01}
                    stepPixelSize={6}
                    value={data.voice_pitch}
                    format={(v) => v.toFixed(2)}
                    onChange={(_, v) =>
                      act('set_voice_pitch_direct', { value: v })
                    }
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Voice Color">
                  <Button onClick={() => act('set_voice_color')}>
                    {data.voice_color}
                  </Button>
                </LabeledList.Item>
                <LabeledList.Item label="Body Type">
                  <Dropdown
                    options={data.body_type_options}
                    selected={data.body_type}
                    onSelected={(val) => act('set_body_type', { value: val })}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Age">
                  <Dropdown
                    options={data.age_options}
                    selected={data.age}
                    onSelected={(val) => act('set_age', { value: val })}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Nickname Color">
                  <Button onClick={() => act('set_highlight_color')}>
                    {data.highlight_color}
                  </Button>
                </LabeledList.Item>
                <LabeledList.Item label="Free Language">
                  <Button onClick={() => act('set_extra_language')}>
                    {data.extra_language}
                  </Button>
                </LabeledList.Item>
                <LabeledList.Item label="Race Bonus">
                  <Button onClick={() => act('set_race_bonus')}>
                    {data.race_bonus}
                  </Button>
                </LabeledList.Item>
              </LabeledList>
            </Section>
            <Section title="Notes">
              <Stack vertical>
                <Stack.Item>
                  <div style={{ marginBottom: '4px', color: '#aaa' }}>
                    Flavor Text
                  </div>
                  <TextArea
                    fluid
                    height="70px"
                    value={data.flavortext}
                    onBlur={(val) => act('set_flavortext', { value: val })}
                    placeholder="Describe your character's physical appearance."
                  />
                </Stack.Item>
                <Stack.Item>
                  <div style={{ marginBottom: '4px', color: '#aaa' }}>
                    OOC Notes
                  </div>
                  <TextArea
                    fluid
                    height="70px"
                    value={data.ooc_notes}
                    onBlur={(val) => act('set_ooc_notes', { value: val })}
                    placeholder="Your OOC preferences."
                  />
                </Stack.Item>
                <Stack.Item>
                  <LabeledList>
                    <LabeledList.Item label="Song URL">
                      <Button onClick={() => act('set_song_url')}>
                        {data.ooc_extra || 'None'}
                      </Button>
                    </LabeledList.Item>
                    <LabeledList.Item label="Song Artist">
                      <Input
                        fluid
                        value={data.song_artist}
                        onEnter={(val) =>
                          act('set_song_artist', { value: val })
                        }
                      />
                    </LabeledList.Item>
                    <LabeledList.Item label="Song Title">
                      <Input
                        fluid
                        value={data.song_title}
                        onEnter={(val) =>
                          act('set_song_title', { value: val })
                        }
                      />
                    </LabeledList.Item>
                  </LabeledList>
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <Section title="Body">
              <LabeledList>
                <LabeledList.Item label="Headshot">
                  <Button onClick={() => act('set_headshot')}>Change</Button>
                </LabeledList.Item>
                <LabeledList.Item label="Sprite Scale">
                  <Button onClick={() => act('set_body_size')}>
                    {data.body_size}%
                  </Button>
                </LabeledList.Item>
                {data.has_skin_tones && (
                  <LabeledList.Item label="Skin Tone">
                    <Button onClick={() => act('set_skin_tone')}>
                      {data.skin_tone}
                    </Button>
                  </LabeledList.Item>
                )}
                {data.has_mutant_colors && (
                  <>
                    <LabeledList.Item label="Mutant Color 1">
                      <Button onClick={() => act('set_mutant_color1')}>
                        {data.mutant_color1}
                      </Button>
                    </LabeledList.Item>
                    <LabeledList.Item label="Mutant Color 2">
                      <Button onClick={() => act('set_mutant_color2')}>
                        {data.mutant_color2}
                      </Button>
                    </LabeledList.Item>
                    <LabeledList.Item label="Mutant Color 3">
                      <Button onClick={() => act('set_mutant_color3')}>
                        {data.mutant_color3}
                      </Button>
                    </LabeledList.Item>
                    <LabeledList.Item label="Auto-Update Colors">
                      <Button
                        selected={data.update_mutant_colors}
                        onClick={() => act('toggle_update_mutant_colors')}
                      >
                        {data.update_mutant_colors ? 'Yes' : 'No'}
                      </Button>
                    </LabeledList.Item>
                  </>
                )}
                <LabeledList.Item label="Features">
                  <Button onClick={() => act('open_features')}>Change</Button>
                </LabeledList.Item>
                <LabeledList.Item label="Markings">
                  <Button onClick={() => act('open_markings')}>Change</Button>
                </LabeledList.Item>
                <LabeledList.Item label="Descriptors">
                  <Button onClick={() => act('open_descriptors')}>
                    Change
                  </Button>
                </LabeledList.Item>
                <LabeledList.Item label="Examine Theme">
                  <Button onClick={() => act('set_examine_theme')}>
                    {data.examine_theme}
                  </Button>
                </LabeledList.Item>
              </LabeledList>
            </Section>
          </Stack.Item>
        </Stack>
      </Stack.Item>
    </Stack>
  );
}

import { Button, LabeledList, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../../backend';
import type { PreferencesData } from './types';

export function GameSettingsPage() {
  const { act, data } = useBackend<PreferencesData>();

  return (
    <Stack fill>
      <Stack.Item grow>
        <Section title="Display">
          <LabeledList>
            <LabeledList.Item label="TGUI Theme">
              <Button onClick={() => act('set_tgui_theme')}>
                {data.tgui_theme}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Ambient Occlusion">
              <Button
                selected={data.ambientocclusion}
                onClick={() => act('toggle_ambientocclusion')}
              >
                {data.ambientocclusion ? 'Enabled' : 'Disabled'}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Window Flashing">
              <Button
                selected={data.windowflashing}
                onClick={() => act('toggle_windowflashing')}
              >
                {data.windowflashing ? 'Enabled' : 'Disabled'}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="FPS">
              <Button onClick={() => act('set_fps')}>
                {data.clientfps === 0 ? 'Sync' : `${data.clientfps}`}
              </Button>
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        <Section title="Special Roles">
          <LabeledList>
            {data.special_roles.map((role) => (
              <LabeledList.Item key={role.name} label={role.name}>
                <Button
                  selected={role.enabled}
                  onClick={() =>
                    act('toggle_special_role', { role: role.name })
                  }
                >
                  {role.enabled ? 'Enabled' : 'Disabled'}
                </Button>
              </LabeledList.Item>
            ))}
          </LabeledList>
        </Section>
      </Stack.Item>
    </Stack>
  );
}

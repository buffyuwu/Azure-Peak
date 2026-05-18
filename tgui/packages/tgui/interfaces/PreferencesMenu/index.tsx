import { useState } from 'react';

import { Tabs } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { IdentityPage } from './Identity';
import type { PreferencesData } from './types';

type Page = 'identity' | 'settings';

export const PreferencesMenu = () => {
  useBackend<PreferencesData>();
  const [page, setPage] = useState<Page>('identity');

  return (
    <Window title="Character Preferences" width={900} height={1000}>
      <Window.Content scrollable>
        <Tabs fluid style={{ textAlign: 'center', textTransform: 'uppercase' }}>
          <Tabs.Tab
            selected={page === 'identity'}
            onClick={() => setPage('identity')}
          >
            Identity
          </Tabs.Tab>
          <Tabs.Tab
            selected={page === 'settings'}
            onClick={() => setPage('settings')}
          >
            Game Settings
          </Tabs.Tab>
        </Tabs>
        {page === 'identity' && <IdentityPage />}
        {page === 'settings' && null}
      </Window.Content>
    </Window>
  );
};

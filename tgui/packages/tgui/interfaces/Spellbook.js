import { useBackend } from '../backend';
import { Window } from '../layouts';
import { GenericUplink } from './Uplink';

export const Spellbook = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    points,
  } = data;
  return (
    <Window
      theme="wizard"
      resizable>
      <Window.Content scrollable>
        <GenericUplink
          currencyAmount={points}
          currencySymbol="MP" />
      </Window.Content>
    </Window>
  );
};

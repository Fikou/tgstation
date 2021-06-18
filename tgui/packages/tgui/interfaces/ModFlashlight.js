import { useBackend } from '../backend';
import { Button, ColorBox, Section } from '../components';
import { Window } from '../layouts';

export const ModFlashlight = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    light_on,
    light_color,
  } = data;
  return (
    <Window
      width={275}
      height={85}>
      <Section>
        <Button
          width="144px"
          icon="lightbulb"
          selected={light_on}
          onClick={() => act('toggle_light')}>
          Flashlight: {light_on ? 'ON' : 'OFF'}
        </Button>
        <Button
          ml={1}
          onClick={() => act('light_color')}>
          Color:
          <ColorBox ml={1} color={light_color} />
        </Button>
      </Section>
    </Window>
  );
};

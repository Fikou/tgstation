import { useBackend, useLocalState } from '../backend';
import { Section, Box, Button } from '../components';
import { Window } from '../layouts';
import { resolveAsset } from '../assets';
import { capitalize } from 'common/string';
import { classes } from 'common/react';

export const Bestiary = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    bestiary_info,
  } = data;
  const [index, setIndex] = useLocalState(context, "currentIndex", null);
  const beast = data.bestiary_info[index];
  return (
    <Window
      width={750}
      height={550}
      resizable
      title="Bestiary">
      <Window.Content
        style={{
          "background-image": `url("${resolveAsset('paper_texture.png')}")`,
          "background-repeat": "repeat",
          "background-color": '#ffebcd',
          "background-size": '480px',
          "color": '#37230a',
        }}>
        <Section
          fill
          backgroundColor="rgba(0, 0, 0, 0.1)"
          fontSize="25px">
          {index !== null && (
            <>
              <span style={{ "font-family": 'Segoe Script', "font-style": 'italic' }}>
                <Box inline textAlign="center" style={{ 'float': 'right' }}>
                  <Box bold>
                    Illustration
                  </Box>
                  <img src={resolveAsset(beast.kills > 0 ? beast.name + '.png' : 'unknown.png')} />
                  <Box>
                    Statistics
                  </Box>
                  <Box fontSize="15px">
                    Kills: {beast.kills}
                  </Box>
                </Box>
                <Box bold>
                  {beast.kills > 0 ? capitalize(beast.name) : '???'}
                </Box>
                {beast.kills > 0 ? beast.desc : 'You have not slain this creature!'}
              </span>
              <Box position="absolute" bottom="0px">
                <Button
                  icon="reply"
                  width="45px"
                  height="45px"
                  color="transparent"
                  textColor="black"
                  tooltip="Home Page"
                  style={{
                    'border-radius': '25px',
                  }}
                  onClick={() => setIndex(null)} />
                <Button
                  icon="arrow-left"
                  width="45px"
                  height="45px"
                  color="transparent"
                  textColor="black"
                  tooltip="Previous Entry"
                  style={{
                    'border-radius': '25px',
                  }}
                  onClick={() => setIndex((index-1+bestiary_info.length)
                   % bestiary_info.length)} />
                <Button
                  icon="arrow-right"
                  width="45px"
                  height="45px"
                  color="transparent"
                  textColor="black"
                  tooltip="Next Entry"
                  style={{
                    'border-radius': '25px',
                  }}
                  onClick={() => setIndex((index+1)
                   % bestiary_info.length)} />
              </Box>
            </>
          ) || (
            <>
              {bestiary_info.map((beast, index) => (
                <Button
                  key={beast.name}
                  width="128px"
                  height="128px"
                  color="transparent"
                  tooltip={beast.kills > 0 ? capitalize(beast.name) : '???'}
                  style={{
                    'border-radius': '64px',
                  }}
                  onClick={() => { setIndex(index); }}>
                  <Box
                    className={classes(['bestiarymobs32x32', beast.icon])} />
                </Button>
              ))}
            </>
          )}
          <Box position="absolute" bottom="5px" right="15px" bold
            style={{ "font-family": 'Segoe Script' }}>
            {index !== null ? index+1 : 0}
          </Box>
        </Section>
      </Window.Content>
    </Window>
  );
};


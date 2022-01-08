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
      width={765}
      height={580}
      title="Bestiary">
      <Window.Content
        scrollable
        style={{
          "background-image": `url("${resolveAsset('paper_texture.png')}")`,
          "background-repeat": "repeat",
          "background-color": '#ffebcd',
          "color": '#37230a',
        }}>
        <Section
          fill={index !== null}
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
                  <Box>
                    Loot
                  </Box>
                  <Box fontSize="15px">
                    {beast.kills > 0 ? (beast.loot.length
                      ? beast.loot.map(loot => (
                        <Box key={loot}>
                          {loot}

                        </Box>
                      )): 'none') : '???'}
                  </Box>
                </Box>
                <Box>
                  <Box bold>
                    {beast.kills > 0 ? capitalize(beast.name) : '???'}
                  </Box>
                  {beast.kills > 0 ? beast.desc : 'You have not slain this creature!'}
                </Box>
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
                  textColor="black"
                  textAlign="left"
                  color="transparent"
                  width="96px"
                  height="96px"
                  tooltip={beast.kills > 0 ? capitalize(beast.name) : '???'}
                  style={{
                    'border-radius': '64px',
                  }}
                  onClick={() => { setIndex(index); }}>
                  <Box
                    className={classes([
                      'bestiarymobs64x64',
                      beast.icon,
                    ])}
                    style={{
                      'transform': 'translate(3px, 16px)',
                    }} />
                  {beast.kills > 0 && '★'}
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


import characters from "../data/characters.json";
import colours from "../data/colours.json";
import menu_scene_ids from "../data/menu_scene_ids.json";

export const sample = <T>(x: T[]): T => x[Math.floor(Math.random() * x.length)];

export const clamp = (num: number, min: number, max: number) => {
  return Math.min(Math.max(num, min), max);
};

export const random_colour_hex = () => sample(colours).hex;

export const get_character_name = (character_id: string) => {
  return characters.find((c) => c.id == character_id).name;
};

export const get_colour_hex_by_id = (
  colour_id: string,
  default_colour_hex: string = "#FFFFF"
) => {
  let colour_object = colours.find((c) => c.id == colour_id);
  if (colour_object === undefined || colour_object === null) {
    return default_colour_hex;
  } else {
    return colour_object.hex;
  }
};

const get_deltad_menu_scene_id = (
  current_scene_id: string,
  delta: number
): string => {
  let menu_index = menu_scene_ids.findIndex((id) => id == current_scene_id);
  let new_menu_index = menu_index + delta;
  if (0 <= new_menu_index && new_menu_index < menu_scene_ids.length) {
    menu_index = new_menu_index;
  }
  return menu_scene_ids[menu_index];
};

export const get_previous_menu_scene_id = (current_scene_id: string): string =>
  get_deltad_menu_scene_id(current_scene_id, -1);
export const get_next_menu_scene_id = (current_scene_id: string): string =>
  get_deltad_menu_scene_id(current_scene_id, 1);

export const set_character_id = (ws: WebSocket, character_id: string) => {
  const data = { action: "set_character_id", character_id: character_id };
  console.log(data);
  ws.send(JSON.stringify(data));
};

export const set_colour_id = (ws: WebSocket, colour_id: string) => {
  const data = { action: "set_colour_id", colour_id: colour_id };
  console.log(data);
  ws.send(JSON.stringify(data));
};

import "dotenv/config";
import {
  Client,
  GatewayIntentBits,
  SlashCommandBuilder,
  ChatInputCommandInteraction,
  Collection,
  SlashCommandOptionsOnlyBuilder,
  ContextMenuCommandBuilder,
  MessageContextMenuCommandInteraction,
  Events,
  MessageFlags
} from "discord.js";


// Define a type for your command
interface Command {
  data:
    | SlashCommandBuilder
    | SlashCommandOptionsOnlyBuilder
    | ContextMenuCommandBuilder;
  execute: (
    interaction:
      | ChatInputCommandInteraction
      | MessageContextMenuCommandInteraction
  ) => Promise<void>;
}

// Extend the Client class to include a commands property
declare module "discord.js" {
  export interface Client {
    commands: Collection<string, Command>;
  }
}

// Create a new Client instance
const client = new Client({
  intents: [
    GatewayIntentBits.MessageContent,
    GatewayIntentBits.GuildMessages,
    GatewayIntentBits.Guilds,
    GatewayIntentBits.GuildMessageReactions,
  ],
});

// Initialize commands collection
client.commands = new Collection();

// Define the help command
const helpCommand: Command = {
  data: new SlashCommandBuilder()
    .setName('help')
    .setDescription('Shows information about the bot'),
  execute: async (interaction: ChatInputCommandInteraction | MessageContextMenuCommandInteraction) => {
    await interaction.reply({
      embeds: [{
        title: 'Fish',
        description: 'Hello! I\'m a fish bot <a:fish:1415001962763649176>\n\nI automatically react with the <a:fish:1415001962763649176> emoji when someone mentions "fish" in their message!\n\nThat\'s all I do',
        color: 0x0099ff
      }]
    });
  }
};

// Add the command to the collection
client.commands.set(helpCommand.data.name, helpCommand);

client.on(Events.ClientReady, async (readyClient) => {
  console.log(`Logged in as ${readyClient.user.tag}!`);
  
  // Register the slash command
  try {
    await readyClient.application?.commands.set([helpCommand.data]);
    console.log('Successfully registered slash commands');
  } catch (error) {
    console.error('Error registering slash commands:', error);
  }
});

client.on(Events.InteractionCreate, async (interaction) => {
  if (!interaction.isChatInputCommand()) return;

  const command = client.commands.get(interaction.commandName);
  if (!command) return;

  try {
    await command.execute(interaction);
  } catch (error) {
    console.error('Error executing command:', error);
    const reply = { content: 'There was an error executing this command!', ephemeral: true };
    
    if (interaction.replied || interaction.deferred) {
      await interaction.followUp(reply);
    } else {
      await interaction.reply(reply);
    }
  }
});

client.on(Events.MessageCreate, async (message) => {
  if (message.author.bot) return;

  console.log(`Message received from ${message.author.tag}: "${message.content}"`);

  if (message.content.toLowerCase().includes("fish")) {
    console.log(`Fish detected in message from ${message.author.tag}, reacting with 🐟`);
    await message.react("1415001962763649176");
    console.log(`Successfully reacted to message from ${message.author.tag}`);
  }
})



client.login(process.env.DISCORD_TOKEN);
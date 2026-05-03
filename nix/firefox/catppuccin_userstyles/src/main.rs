use std::{
	collections::HashMap,
	fs::{read_to_string, write},
};

use clap::{Parser, Subcommand};
use cssparser::{ParseError, Parser as CSSParser, ParserInput, ToCss, TokenSerializationType};
use glob::glob;

#[derive(Parser)]
#[command(version, about, long_about = None)]
#[command(propagate_version = true)]
struct Cli {
	#[command(subcommand)]
	command: Commands,
}

#[derive(Subcommand)]
enum Commands {
	Domains {
		userstyles: Vec<String>,
		output: String,
	},
	StylusDeclarative {
		light_flavor: String,
		dark_flavor: String,
		accent_color: String,
		output: String,
	},
}

fn domains(userstyles: Vec<String>, output: String) {
	let mut domains: Vec<String> = Vec::new();
	for userstyle in userstyles.iter() {
		let userstyle_code = read_to_string(userstyle).unwrap();
		let mut parserinput = ParserInput::new(userstyle_code.as_str());
		let mut parser = CSSParser::new(&mut parserinput);
		parser
			.parse_entirely(|input| {
				loop {
					match input.next() {
						Err(e) if e.kind == cssparser::BasicParseErrorKind::EndOfInput => {
							break;
						}
						Err(e) => {
							eprintln!("{e:?}");
							break;
						}
						Ok(token) => {
							if token.serialization_type() == TokenSerializationType::Function
								&& token.to_css_string() == "domain("
							{
								input
									.parse_nested_block(|input| {
										let css_string = input.next().unwrap().to_css_string();
										let mut chars = css_string.chars();
										chars.next();
										chars.next_back();
										if chars.as_str().to_string() == "mail.google.com" {
											// skip the gmail userstyle
											// https://github.com/catppuccin/userstyles/issues/1427
											// also running dark reader on emails
											return Ok::<(), ParseError<()>>(());
										}
										domains.push(chars.as_str().to_string());
										Ok::<(), ParseError<()>>(())
									})
									.unwrap();
							}
						}
					}
				}
				Ok::<(), ParseError<()>>(())
			})
			.unwrap();
	}
	write(output, serde_json::to_string(&domains).unwrap()).unwrap();
}

#[derive(serde::Serialize)]
struct UserStyleDeclarative {
	code: String,
	variables: Option<HashMap<String, String>>,
}

fn stylus_declarative(
	light_flavor: String,
	dark_flavor: String,
	accent_color: String,
	output: String,
) {
	let mut userstyles_declarative: Vec<UserStyleDeclarative> = Vec::new();
	for style in glob("./styles/*/catppuccin.user.less").unwrap() {
		match style {
			Ok(path) => {
				if path.to_string_lossy().contains("gmail") {
					// skip gmail, see above
					break;
				}
				userstyles_declarative.push(UserStyleDeclarative {
					code: read_to_string(path).unwrap(),
					variables: Some(HashMap::from([
						("lightFlavor".to_string(), light_flavor.clone()),
						("darkFlavor".to_string(), dark_flavor.clone()),
						("accentColor".to_string(), accent_color.clone()),
					])),
				});
			}
			Err(e) => println!("{:?}", e),
		}
	}
	write(
		output,
		serde_json::to_string(&userstyles_declarative).unwrap(),
	)
	.unwrap()
}

fn main() {
	let cli = Cli::parse();

	match &cli.command {
		Commands::Domains { userstyles, output } => {
			domains(userstyles.to_vec(), output.to_string())
		}
		Commands::StylusDeclarative {
			light_flavor,
			dark_flavor,
			accent_color,
			output,
		} => {
			stylus_declarative(
				light_flavor.to_string(),
				dark_flavor.to_string(),
				accent_color.to_string(),
				output.to_string(),
			);
		}
	}
}

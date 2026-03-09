use abi_stable::std_types::{ROption, RString, RVec};
use anyrun_plugin::*;
use std::process::Command;

struct SystemAction {
    id: u64,
    name: &'static str,
    title: &'static str,
    icon: &'static str,
    command: &'static str,
}

const ACTIONS: &[SystemAction] = &[
    SystemAction {
        id: 0,
        name: "lock",
        title: "Lock Screen",
        icon: "system-lock-screen",
        command: "loginctl lock-session",
    },
    SystemAction {
        id: 1,
        name: "logout",
        title: "Log out",
        icon: "system-log-out",
        command: "loginctl terminate-user $USER",
    },
    SystemAction {
        id: 2,
        name: "suspend",
        title: "Suspend",
        icon: "system-suspend",
        command: "systemctl suspend",
    },
    SystemAction {
        id: 3,
        name: "hibernate",
        title: "Hibernate",
        icon: "system-hibernate",
        command: "systemctl hibernate",
    },
    SystemAction {
        id: 4,
        name: "reboot",
        title: "Reboot",
        icon: "system-reboot",
        command: "systemctl reboot",
    },
    SystemAction {
        id: 5,
        name: "shutdown",
        title: "Shut down",
        icon: "system-shutdown",
        command: "systemctl poweroff",
    },
];

#[init]
fn init(_config_dir: RString) -> () {
    println!("System plugin initialized");
}

#[info]
fn info() -> PluginInfo {
    PluginInfo {
        name: "System".into(),
        icon: "system-shutdown".into(),
    }
}

#[get_matches]
fn get_matches(input: RString, _data: &mut ()) -> RVec<Match> {
    let input_str = input.to_string().to_lowercase();
    eprintln!("System plugin searching for: '{}'", input_str);

    let matches: Vec<Match> = ACTIONS
        .iter()
        .filter(|action| {
            input_str.is_empty()
                || action.title.to_lowercase().contains(&input_str)
                || action.name.contains(&input_str)
        })
        .map(|action| Match {
            title: action.title.into(),
            icon: ROption::RSome(action.icon.into()),
            use_pango: false,
            description: ROption::RSome(format!("Execute: {}", action.command).into()),
            id: ROption::RSome(action.id),
        })
        .collect();

    eprintln!("System plugin found {} matches", matches.len());
    matches.into()
}

#[handler]
fn handler(selection: Match, _data: &mut ()) -> HandleResult {
    if let ROption::RSome(id) = selection.id {
        if let Some(action) = ACTIONS.iter().find(|a| a.id == id) {
            eprintln!("Executing command: {}", action.command);
            let _ = Command::new("sh").arg("-c").arg(action.command).spawn();
        }
    }
    HandleResult::Close
}

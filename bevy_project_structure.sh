#!/bin/bash

# Script to create the project structure for press_brake_sim_bevy

PROJECT_NAME="press_brake_sim_bevy"

# --- Helper function to create file with content ---
# $1: File path
# $2: File content (passed as a single string, newlines preserved by quotes)
create_file_with_content() {
  echo "Creating file: $1"
  # Ensure parent directory exists
  mkdir -p "$(dirname "$1")"
  cat <<EOF >"$1"
$2
EOF
}

echo "Creating project structure for $PROJECT_NAME..."

# --- Create root project directory ---
if [ -d "$PROJECT_NAME" ]; then
  echo "Warning: Project directory '$PROJECT_NAME' already exists."
else
  mkdir "$PROJECT_NAME"
  echo "Created directory: $PROJECT_NAME"
fi
cd "$PROJECT_NAME" || exit 1 # Exit if cd fails

# --- Create assets directory and subdirectories ---
mkdir -p assets/fonts
echo "Created directory: assets/fonts"
touch assets/fonts/"# (Optional) Place Bevy fonts like FiraSans-Bold.ttf here"
touch assets/"# Placeholder for app_logo.png"
touch assets/"# Placeholder for icon.png"
touch assets/"# Placeholder for main_background.png"
echo "Created asset placeholders."

# --- Create jobs directory ---
mkdir -p jobs
echo "Created directory: jobs"

# --- Create src directory and subdirectories ---
mkdir -p src/core_logic
mkdir -p src/bevy_render
mkdir -p src/egui_interface/panels
echo "Created src subdirectories."

# --- Populate src files ---

# src/main.rs
MAIN_RS_CONTENT='// src/main.rs
// Main Bevy application entry point and plugin setup

// Declare modules
mod state;
mod core_logic;
mod bevy_render;
mod egui_interface;
// mod common_utils; // Uncomment if you use it

use bevy::prelude::*;
use bevy_egui::EguiPlugin;

// Import plugins from your modules (they need to be defined)
// use bevy_render::RenderPlugin; // Example
// use egui_interface::InterfacePlugin; // Example
use state::AppState; // Assuming AppState is directly usable as a resource or wrapped

fn main() {
    println!("Starting Bevy App (placeholder)...");
    App::new()
        .add_plugins(DefaultPlugins.set(WindowPlugin {
            primary_window: Some(Window {
                title: "Press Brake CNC Simulator".into(),
                // resolution: (1280.0, 960.0).into(), // Set initial window size
                // present_mode: bevy::window::PresentMode::AutoVsync,
                ..default()
            }),
            ..default()
        }))
        .add_plugins(EguiPlugin)
        // .add_plugins(RenderPlugin) // Add your custom render plugin
        // .add_plugins(InterfacePlugin) // Add your custom egui interface plugin
        .init_resource::<AppState>() // Or your wrapped AppState
        .add_systems(Startup, setup)
        // .add_systems(Update, ...) // Add your systems
        .run();
}

fn setup(mut commands: Commands, /* asset_server: Res<AssetServer> */) {
    // Spawn a 2D camera
    commands.spawn(Camera2dBundle::default());
    // Initial setup logic, e.g., loading assets
    println!("Bevy setup complete.");
}'
create_file_with_content "src/main.rs" "$MAIN_RS_CONTENT"

# src/state.rs
STATE_RS_CONTENT='// src/state.rs
// Core application data structures (AppState, Job, etc.)
// AppState will be a Bevy Resource.

use bevy::prelude::*;
use bevy::utils::HashMap; // Use Bevy'\''s HashMap if preferred, or std::collections::HashMap
use serde::{Serialize, Deserialize};
// use egui::Color32; // If Color32 is still used for status messages, ensure egui is a dependency
// use dxf; // Uncomment when dxf crate is added to Cargo.toml and `use dxf;` is added.

/*
Example of how to handle doc comments that might use triple quotes:
/**
 * This is a doc comment.
 */
*/

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Serialize, Deserialize, Default)]
pub enum MaterialName {
    #[default]
    Steel,
    Aluminum,
    StainlessSteel,
    Copper,
    MildSteel,
    // Custom(String), // Decide if you still need this variant
}

impl MaterialName {
    // pub fn default_names() -> Vec<Self> { ... }
    pub fn to_display_string(&self) -> String {
        match self {
            MaterialName::Steel => "Steel".to_string(),
            MaterialName::Aluminum => "Aluminum".to_string(),
            MaterialName::StainlessSteel => "Stainless Steel".to_string(),
            MaterialName::Copper => "Copper".to_string(),
            MaterialName::MildSteel => "Mild Steel".to_string(),
            // MaterialName::Custom(name) => name.clone(),
        }
    }
}


#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct MaterialDetails {
    pub name: MaterialName,
    pub density_kg_m3: f64,
    pub yield_stress_mpa: f64,
    pub tensile_modulus_gpa: f64,
    pub min_bend_radius_factor: f64,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize, Default)]
pub enum BendDirection {
    #[default]
    Up,
    Down,
}
impl BendDirection {
    // pub fn default_directions() -> Vec<Self> { ... }
    pub fn to_display_string(&self) -> String {
        match self {
            BendDirection::Up => "Up".to_string(),
            BendDirection::Down => "Down".to_string(),
        }
    }
}


#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct BendStep {
    pub sequence_order: usize,
    pub position_mm: f64,
    pub target_angle_deg: f64,
    pub radius_mm: f64,
    pub direction: BendDirection,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct SheetMetal {
    pub id: String,
    pub original_length_mm: f64,
    pub thickness_mm: f64,
    pub width_mm: f64,
    pub material_name: MaterialName,
}

impl Default for SheetMetal {
    fn default() -> Self {
        Self {
            id: "DefaultSheet-001".to_string(),
            original_length_mm: 300.0,
            thickness_mm: 2.0,
            width_mm: 100.0,
            material_name: MaterialName::Steel,
        }
    }
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct Punch {
    pub name: String,
    pub height_mm: f64,
    pub angle_deg: f64,
    pub radius_mm: f64,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct Die {
    pub name: String,
    pub v_opening_mm: f64,
    pub angle_deg: f64,
    pub shoulder_radius_mm: f64,
}


#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct Job {
    pub name: String,
    pub sheet: SheetMetal,
    pub steps: Vec<BendStep>,
}

impl Default for Job {
    fn default() -> Self {
        Self {
            name: "DefaultJob-001".to_string(),
            sheet: SheetMetal::default(),
            steps: Vec::new(),
        }
    }
}

// --- UI Input State (transient, not typically saved with the Job itself) ---
#[derive(Default, Clone, Resource)] 
pub struct SheetInputState {
    pub length_mm_str: String,
    pub thickness_mm_str: String,
    pub width_mm_str: String,
    pub selected_material_idx: usize,
}

#[derive(Default, Clone, Resource)] 
pub struct BendInputState {
    pub position_mm_str: String,
    pub target_angle_deg_str: String,
    pub radius_mm_str: String,
    pub selected_direction_idx: usize,
}

#[derive(Default, Clone, Resource)]
pub struct ToolingInputState {
    pub selected_punch_idx: usize,
    pub selected_die_idx: usize,
}


// --- DXF View Control State ---
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum DxfViewPreset {
    XY, 
    XZ, 
    YZ, 
    Isometric,
}

impl Default for DxfViewPreset { fn default() -> Self { DxfViewPreset::XY } }

impl DxfViewPreset {
    pub fn to_display_string(&self) -> String {
        match self {
            DxfViewPreset::XY => "Front (XY)".to_string(),
            DxfViewPreset::XZ => "Top (XZ)".to_string(),
            DxfViewPreset::YZ => "Side (YZ)".to_string(),
            DxfViewPreset::Isometric => "Isometric".to_string(),
        }
    }
    pub fn all() -> Vec<Self> {
        vec![DxfViewPreset::XY, DxfViewPreset::XZ, DxfViewPreset::YZ, DxfViewPreset::Isometric]
    }
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize, Resource)] 
pub struct DxfViewControls {
    pub preset: DxfViewPreset,
    pub scale: f32,
    pub offset: Vec2, 
    pub rotation_degrees: Vec2, 
}

impl Default for DxfViewControls {
    fn default() -> Self {
        Self {
            preset: DxfViewPreset::XY,
            scale: 1.0,
            offset: Vec2::ZERO,
            rotation_degrees: Vec2::new(35.264, 45.0), 
        }
    }
}


// --- Main Application State ---
#[derive(Resource)] 
pub struct AppState {
    pub current_job: Job,
    pub available_materials: HashMap<MaterialName, MaterialDetails>,
    pub material_display_order: Vec<MaterialName>, 

    pub available_punches: Vec<Punch>,
    pub available_dies: Vec<Die>,

    pub sheet_input: SheetInputState,
    pub bend_input: BendInputState,
    pub tooling_input: ToolingInputState,
    pub dxf_view_controls: DxfViewControls,

    pub simulation_status: String,
    pub parts_bent_session: u32,

    pub profile_load_status: String,
    
    // DXF specific state
    // Make sure to add `dxf = "version"` to your Cargo.toml and `use dxf;` at the top.
    pub loaded_dxf_drawing: Option<dxf::Drawing>,

    pub status_message_text: String,
    pub status_message_is_error: bool, 
}

impl Default for AppState {
    fn default() -> Self {
        let mut materials = HashMap::default();
        materials.insert(MaterialName::Steel, MaterialDetails { name: MaterialName::Steel, density_kg_m3: 7850.0, yield_stress_mpa: 250.0, tensile_modulus_gpa: 200.0, min_bend_radius_factor: 1.5 });
        materials.insert(MaterialName::Aluminum, MaterialDetails { name: MaterialName::Aluminum, density_kg_m3: 2700.0, yield_stress_mpa: 100.0, tensile_modulus_gpa: 70.0, min_bend_radius_factor: 1.0 });
        // Add other materials...
        
        let material_display_order = vec![MaterialName::Steel, MaterialName::Aluminum /* ... */];

        let punches = vec![
            Punch { name: "P88.10.R06".to_string(), height_mm: 60.0, angle_deg: 88.0, radius_mm: 0.6 },
            // Add other punches...
        ];
        let dies = vec![
            Die { name: "D12.90.R2".to_string(), v_opening_mm: 12.0, angle_deg: 90.0, shoulder_radius_mm: 2.0 },
            // Add other dies...
        ];
        
        let current_job = Job::default();
        let sheet_input = SheetInputState {
            length_mm_str: current_job.sheet.original_length_mm.to_string(),
            thickness_mm_str: current_job.sheet.thickness_mm.to_string(),
            width_mm_str: current_job.sheet.width_mm.to_string(),
            selected_material_idx: material_display_order
                .iter()
                .position(|name| *name == current_job.sheet.material_name)
                .unwrap_or(0),
        };

        Self {
            current_job,
            available_materials: materials,
            material_display_order,
            available_punches: punches,
            available_dies: dies,
            sheet_input,
            bend_input: BendInputState::default(),
            tooling_input: ToolingInputState::default(),
            dxf_view_controls: DxfViewControls::default(),
            simulation_status: "Ready".to_string(),
            parts_bent_session: 0,
            profile_load_status: "Profile not generated.".to_string(),
            loaded_dxf_drawing: None, // Initialize as None
            status_message_text: "System Initialized. Welcome!".to_string(),
            status_message_is_error: false,
        }
    }
}'
create_file_with_content "src/state.rs" "$STATE_RS_CONTENT"

# src/common_utils.rs
COMMON_UTILS_CONTENT='// src/common_utils.rs
// (Optional) Shared utilities, types, or constants

// Example:
// pub const DEFAULT_PRECISION: f64 = 0.01;
'
create_file_with_content "src/common_utils.rs" "$COMMON_UTILS_CONTENT"

# --- src/core_logic ---
CORE_LOGIC_MOD_CONTENT='// src/core_logic/mod.rs

pub mod simulation;
pub mod validation;
pub mod file_io;
'
create_file_with_content "src/core_logic/mod.rs" "$CORE_LOGIC_MOD_CONTENT"

GENERIC_BEVY_FILE_CONTENT='// Placeholder
use bevy::prelude::*;
// Add other necessary imports
'
create_file_with_content "src/core_logic/simulation.rs" "$GENERIC_BEVY_FILE_CONTENT"
create_file_with_content "src/core_logic/validation.rs" "$GENERIC_BEVY_FILE_CONTENT"
create_file_with_content "src/core_logic/file_io.rs" "$GENERIC_BEVY_FILE_CONTENT"

# --- src/bevy_render ---
BEVY_RENDER_MOD_CONTENT='// src/bevy_render/mod.rs
// Bevy plugin for rendering features

// pub mod camera_control; // Example
// pub mod dxf_visuals;    // Example
// pub mod viewport_input; // Example

// use bevy::prelude::*;

// pub struct RenderPlugin;

// impl Plugin for RenderPlugin {
//     fn build(&self, app: &mut App) {
//         app.add_systems(Update, (
//             // camera_control::camera_control_system,
//             // dxf_visuals::dxf_visualization_system,
//             // viewport_input::bevy_view_input_system,
//         ));
//         // Add other setup like resources here
//         println!("RenderPlugin loaded (placeholder)");
//    }
// }
'
create_file_with_content "src/bevy_render/mod.rs" "$BEVY_RENDER_MOD_CONTENT"
create_file_with_content "src/bevy_render/camera_control.rs" "$GENERIC_BEVY_FILE_CONTENT"
create_file_with_content "src/bevy_render/dxf_visuals.rs" "$GENERIC_BEVY_FILE_CONTENT"
create_file_with_content "src/bevy_render/viewport_input.rs" "$GENERIC_BEVY_FILE_CONTENT"

# --- src/egui_interface ---
EGUI_INTERFACE_MOD_CONTENT='// src/egui_interface/mod.rs
// Bevy plugin for egui setup and the main UI system

// pub mod main_ui_system;
// pub mod panels;

// use bevy::prelude::*;

// pub struct InterfacePlugin;

// impl Plugin for InterfacePlugin {
//     fn build(&self, app: &mut App) {
//         app.add_systems(Update, main_ui_system::update_egui_system);
//         // Add other setup like egui contexts or styles
//         println!("InterfacePlugin loaded (placeholder)");
//     }
// }
'
create_file_with_content "src/egui_interface/mod.rs" "$EGUI_INTERFACE_MOD_CONTENT"

EGUI_MAIN_UI_SYSTEM_CONTENT='// src/egui_interface/main_ui_system.rs
// Top-level egui system orchestrating all egui panels & menu

use bevy::prelude::*;
use bevy_egui::{egui, EguiContexts};
use crate::state::AppState; // Your AppState
// use crate::core_logic::file_io; // For load/save logic
// use super::panels; // To call panel drawing functions

pub fn update_egui_system(
    mut contexts: EguiContexts,
    mut app_state: ResMut<AppState>,
    // query_windows: Query<&Window, With<PrimaryWindow>>, // For window interaction
) {
    let ctx = contexts.ctx_mut();

    egui::TopBottomPanel::top("top_menu_bar").show(ctx, |ui| {
        egui::menu::bar(ui, |ui| {
            ui.menu_button("File", |ui| {
                if ui.button("Load Job...").clicked() {
                    // Call logic to load job, e.g., using rfd
                    // let path = rfd::FileDialog::new().pick_file();
                    // if let Some(p) = path {
                    //    match file_io::load_job_from_file(&p.to_string_lossy(), &mut app_state) { ... }
                    // }
                    app_state.status_message_text = "File > Load Job clicked (placeholder)".to_string();
                    ui.close_menu();
                }
                // Add other menu items (Save, Exit)
                if ui.button("Exit").clicked() {
                    // app.exit(); // Bevy'\''s app exit, might need EventWriter<AppExit>
                     app_state.status_message_text = "File > Exit clicked (placeholder)".to_string();
                }
            });
            // Add other menus (View, Help)
        });
    });

    egui::SidePanel::left("left_controls_panel")
        .default_width(350.0)
        .show(ctx, |ui| {
            ui.heading("Controls");
            ui.separator();
            // panels::sheet_properties::sheet_properties_panel(ui, &mut app_state);
            // ui.separator();
            // panels::tooling_setup::tooling_setup_panel(ui, &mut app_state);
            // ... and so on for other panels
            ui.label("Sheet Properties (placeholder)");
            ui.label("Tooling Setup (placeholder)");
            ui.label("Bend Definition (placeholder)");
    });

    egui::CentralPanel::default().show(ctx, |ui| {
        ui.heading("Main View / DXF Area");
        ui.label("Bevy will render DXF content here (behind or alongside egui).");
        ui.separator();
        // panels::view_controls::view_controls_panel(ui, &mut app_state.dxf_view_controls);
        ui.label("View Controls (placeholder for zoom, pan, preset buttons)");
    });
    
    egui::TopBottomPanel::bottom("bottom_status_bar").show(ctx, |ui| {
        ui.horizontal(|ui| {
            // ui.label(format!("Status: {}", app_state.status_message_text));
            // if app_state.status_message_is_error { ... color it red ... }
            ui.label(&app_state.status_message_text);
        });
    });
}
'
create_file_with_content "src/egui_interface/main_ui_system.rs" "$EGUI_MAIN_UI_SYSTEM_CONTENT"

# --- src/egui_interface/panels ---
EGUI_PANELS_MOD_CONTENT='// src/egui_interface/panels/mod.rs

// pub mod sheet_properties;
// pub mod tooling_setup;
// pub mod bend_definition;
// pub mod bend_sequence;
// pub mod execution_controls;
// pub mod view_controls;
'
create_file_with_content "src/egui_interface/panels/mod.rs" "$EGUI_PANELS_MOD_CONTENT"

GENERIC_EGUI_PANEL_CONTENT='// src/egui_interface/panels/panel_name.rs
// Placeholder for panel UI

// use bevy_egui::egui;
// use crate::state::AppState; // Or specific parts of it

// pub fn draw_my_panel(ui: &mut egui::Ui, app_state: &mut AppState) {
//    ui.heading("My Panel (Placeholder)");
//    // Add egui widgets here
// }
'
create_file_with_content "src/egui_interface/panels/sheet_properties.rs" "$GENERIC_EGUI_PANEL_CONTENT"
create_file_with_content "src/egui_interface/panels/tooling_setup.rs" "$GENERIC_EGUI_PANEL_CONTENT"
create_file_with_content "src/egui_interface/panels/bend_definition.rs" "$GENERIC_EGUI_PANEL_CONTENT"
create_file_with_content "src/egui_interface/panels/bend_sequence.rs" "$GENERIC_EGUI_PANEL_CONTENT"
create_file_with_content "src/egui_interface/panels/execution_controls.rs" "$GENERIC_EGUI_PANEL_CONTENT"
create_file_with_content "src/egui_interface/panels/view_controls.rs" "$GENERIC_EGUI_PANEL_CONTENT"

# --- Cargo.toml ---
CARGO_TOML_CONTENT='[package]
name = "'"$PROJECT_NAME"'"
version = "0.1.0"
edition = "2021"

# See more keys and their definitions at https://doc.rust-lang.org/cargo/reference/manifest.html

[dependencies]
bevy = "0.13" # Check for the latest Bevy version
bevy_egui = "0.28" # Check for latest bevy_egui, ensure compatibility with Bevy version
bevy_prototype_lyon = "0.11" # For 2D shape rendering

# Add your existing dependencies here, ensuring version compatibility:
dxf = "0.6" # Or your current version
serde = { version = "1.0", features = ["derive"] }
serde_json = "1.0"
chrono = { version = "0.4", features = ["serde"] }
rfd = "0.14" # For native file dialogs
thiserror = "1.0"
log = "0.4"
# image = { version = "0.25", default-features = false, features = ["png", "jpeg"] } # If needed

[profile.dev]
opt-level = 1 

[profile.dev.package."*"]
opt-level = 3

[profile.release]
lto = "thin" 
codegen-units = 1
# Consider enabling link-time optimization for release builds
# strip = true # Strip symbols from binary
'
create_file_with_content "Cargo.toml" "$CARGO_TOML_CONTENT"

# --- .gitignore ---
GITIGNORE_CONTENT='# Generated by Cargo
# will have compiled files and locks
**/target/
Cargo.lock

# IDEs
.idea/
.vscode/
*.code-workspace

# OS generated files
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

# Rider
*.sln.DotSettings.user
*.suo
*.user
*.userosscache
*.sln.docstates
*.config/resharper-host/SourcesCache
*.config/resharper-host/Temp
*_i.c
*_p.c
*_i.h
*.ncb
*.VC.db
*.vcxproj.user
*.vcxproj.filters
*.pdb
*.ilk
*.aps
*.unityproj
*.csproj.user
*.unity.build-cache
*.[Bb]in
*.[Oo]bj
*.[Ll]ib
*.[Ss]o
*.[Dd]ll
*.[Aa]
*.[Aa]r
*.[Ee]xe
*.[Mm]od
*.[Ss]ym
*.[Pp]atch
*.[Mm]eta
*.orig
*.rej
*.swp
*.swo
*~
*.bak
*.tmp
*.orig
*.stackdump

# Rust
# These are backup files generated by rustfmt
**/*.rs.bk
'
create_file_with_content ".gitignore" "$GITIGNORE_CONTENT"

# --- jobs/sample_job.json ---
SAMPLE_JOB_JSON_CONTENT='{
  "name": "SampleJob-001",
  "sheet": {
    "id": "SampleSheet-001",
    "original_length_mm": 250.0,
    "thickness_mm": 1.5,
    "width_mm": 75.0,
    "material_name": "Steel"
  },
  "steps": [
    {
      "sequence_order": 1,
      "position_mm": 50.0,
      "target_angle_deg": 90.0,
      "radius_mm": 2.0,
      "direction": "Up"
    },
    {
      "sequence_order": 2,
      "position_mm": 150.0,
      "target_angle_deg": 45.0,
      "radius_mm": 2.5,
      "direction": "Down"
    }
  ]
}'
create_file_with_content "jobs/sample_job.json" "$SAMPLE_JOB_JSON_CONTENT"

echo ""
echo "Project structure for '$PROJECT_NAME' created successfully."
echo "---------------------------------------------------------"
echo "Next steps:"
echo "1. Manually copy your actual image assets (app_logo.png, icon.png, etc.)"
echo "   into the '$PROJECT_NAME/assets/' folder."
echo "2. Review and complete '$PROJECT_NAME/Cargo.toml' with all your original project"
echo "   dependencies, ensuring correct versions (especially for the 'dxf' crate)."
echo "3. Begin migrating your Rust code from 'backup_sim_press_brake_working/src'"
echo "   into the new files within '$PROJECT_NAME/src/', adapting it for the Bevy architecture."
echo "   - Pay close attention to the placeholder comments in the generated .rs files."
echo "   - You will need to implement the Bevy plugins and systems."
echo "   - Update 'use' statements and module paths as needed."
echo "4. Make sure to uncomment and implement the plugin structures and systems"
echo "   in 'src/bevy_render/mod.rs', 'src/egui_interface/mod.rs', and 'src/main.rs'."
echo "5. The 'src/state.rs' file now includes 'pub loaded_dxf_drawing: Option<dxf::Drawing>'. Ensure"
echo "   the 'dxf' crate is correctly listed in Cargo.toml and add 'use dxf;' at the top of state.rs."

pub const VERTEX_SHADER: &str = r#"
struct PointLight {
    position_radius: vec4<f32>,
    color_pad: vec4<f32>,
}

const MAX_LIGHTS: u32 = 32u;

struct Uniforms {
    view_proj: mat4x4<f32>,
    ambient_color: vec4<f32>,
    fog_color: vec4<f32>,
    fog_params: vec4<f32>,
    camera_pos: vec4<f32>,
    diffuse_color: vec4<f32>,
    lights: array<PointLight, 32>,
}
@group(0) @binding(0) var<uniform> uniforms: Uniforms;

@group(1) @binding(0) var texture_sampler: sampler;
@group(1) @binding(1) var texture: texture_2d<f32>;

struct VertexInput {
    @location(0) position: vec3<f32>,
    @location(1) normal: vec3<f32>,
    @location(2) uv: vec2<f32>,
    @location(3) color: vec4<f32>,
    @location(4) instance_row0: vec4<f32>,
    @location(5) instance_row1: vec4<f32>,
    @location(6) instance_row2: vec4<f32>,
    @location(7) instance_row3: vec4<f32>,
}

struct VertexOutput {
    @builtin(position) position: vec4<f32>,
    @location(0) color: vec4<f32>,
    @location(1) world_normal: vec3<f32>,
    @location(2) uv: vec2<f32>,
    @location(3) world_pos: vec3<f32>,
}

@vertex
fn vs_main(input: VertexInput) -> VertexOutput {
    var output: VertexOutput;
    let model_mat = mat4x4<f32>(
        input.instance_row0,
        input.instance_row1,
        input.instance_row2,
        input.instance_row3,
    );
    let world_pos = model_mat * vec4<f32>(input.position, 1.0);
    output.position = uniforms.view_proj * world_pos;
    output.color = input.color;
    output.world_normal = (model_mat * vec4<f32>(input.normal, 0.0)).xyz;
    output.uv = input.uv;
    output.world_pos = world_pos.xyz;
    return output;
}

@fragment
fn fs_main(input: VertexOutput) -> @location(0) vec4<f32> {
    let tex_color = textureSample(texture, texture_sampler, input.uv);
    var final_color = input.color * tex_color;
    if uniforms.ambient_color.w > 0.5 {
        // Full lighting: directional sun + ambient + point lights
        let light_dir = normalize(vec3<f32>(0.5, 1.0, 0.3));
        let ambient = uniforms.ambient_color.xyz;
        let diffuse = max(dot(normalize(input.world_normal), light_dir), 0.0) * uniforms.diffuse_color.xyz;
        var lighting = ambient + diffuse;
        let num_lights = min(u32(uniforms.fog_params.z), MAX_LIGHTS);
        let world_norm = normalize(input.world_normal);
        for (var i = 0u; i < num_lights; i++) {
            let pl = uniforms.lights[i];
            let to_light = pl.position_radius.xyz - input.world_pos;
            let dist_sq = dot(to_light, to_light);
            let radius = pl.position_radius.w;
            let atten = radius / (radius + dist_sq);
            let ndotl = max(dot(world_norm, normalize(to_light)), 0.0);
            lighting += pl.color_pad.rgb * ndotl * atten;
        }
        final_color = vec4<f32>(final_color.rgb * lighting, final_color.a);
    } else {
        // Dim scene when lighting is off so the toggle is visible
        final_color = vec4<f32>(final_color.rgb * vec3<f32>(0.5), final_color.a);
    }
    let fog_amount = uniforms.fog_params.x;
    let fog_dist = uniforms.fog_params.y;
    if fog_amount > 0.0 && fog_dist > 0.0 {
        let view_dist = distance(input.world_pos, uniforms.camera_pos.xyz);
        let factor = clamp(view_dist / fog_dist, 0.0, 1.0) * fog_amount;
        final_color = mix(final_color, uniforms.fog_color, factor);
    }
    if final_color.a < 0.01 { discard; }
    return final_color;
}
"#;

fn create_depth_stencil(format: Option<wgpu::TextureFormat>) -> Option<wgpu::DepthStencilState> {
    format.map(|f| wgpu::DepthStencilState {
        format: f,
        depth_write_enabled: true,
        depth_compare: wgpu::CompareFunction::Less,
        stencil: wgpu::StencilState::default(),
        bias: wgpu::DepthBiasState::default(),
    })
}

fn create_depth_stencil_overlay(format: Option<wgpu::TextureFormat>) -> Option<wgpu::DepthStencilState> {
    format.map(|f| wgpu::DepthStencilState {
        format: f,
        depth_write_enabled: false,
        depth_compare: wgpu::CompareFunction::Always,
        stencil: wgpu::StencilState::default(),
        bias: wgpu::DepthBiasState::default(),
    })
}

fn create_depth_stencil_walkmesh(format: Option<wgpu::TextureFormat>) -> Option<wgpu::DepthStencilState> {
    format.map(|f| wgpu::DepthStencilState {
        format: f,
        depth_write_enabled: false,
        depth_compare: wgpu::CompareFunction::Less,
        stencil: wgpu::StencilState::default(),
        bias: wgpu::DepthBiasState {
            constant: -2,
            slope_scale: -1.0,
            clamp: 0.0,
        },
    })
}

pub fn create_pipeline(
    device: &wgpu::Device,
    config: &wgpu::SurfaceConfiguration,
    uniform_bind_group_layout: &wgpu::BindGroupLayout,
    texture_bind_group_layout: &wgpu::BindGroupLayout,
    depth_format: Option<wgpu::TextureFormat>,
) -> wgpu::RenderPipeline {
    _create_pipeline_with_cull(device, config.format, uniform_bind_group_layout, texture_bind_group_layout, depth_format, None)
}

pub fn create_pipeline_with_depth(
    device: &wgpu::Device,
    color_format: wgpu::TextureFormat,
    uniform_bind_group_layout: &wgpu::BindGroupLayout,
    texture_bind_group_layout: &wgpu::BindGroupLayout,
    depth_format: Option<wgpu::TextureFormat>,
) -> wgpu::RenderPipeline {
    _create_pipeline_with_cull(device, color_format, uniform_bind_group_layout, texture_bind_group_layout, depth_format, None)
}

pub fn create_tile_pipeline(
    device: &wgpu::Device,
    color_format: wgpu::TextureFormat,
    uniform_bind_group_layout: &wgpu::BindGroupLayout,
    texture_bind_group_layout: &wgpu::BindGroupLayout,
    depth_format: Option<wgpu::TextureFormat>,
) -> wgpu::RenderPipeline {
    _create_pipeline_with_cull(device, color_format, uniform_bind_group_layout, texture_bind_group_layout, depth_format, Some(wgpu::Face::Back))
}

fn create_overlay_pipeline_impl(
    label: &str,
    device: &wgpu::Device,
    color_format: wgpu::TextureFormat,
    uniform_bind_group_layout: &wgpu::BindGroupLayout,
    texture_bind_group_layout: &wgpu::BindGroupLayout,
    _depth_format: Option<wgpu::TextureFormat>,
    depth_stencil: Option<wgpu::DepthStencilState>,
) -> wgpu::RenderPipeline {
    let shader = device.create_shader_module(wgpu::ShaderModuleDescriptor {
        label: Some(&format!("nwn3d_{}_shader", label)),
        source: wgpu::ShaderSource::Wgsl(VERTEX_SHADER.into()),
    });

    let per_vertex_layout = wgpu::VertexBufferLayout {
        array_stride: std::mem::size_of::<[f32; 12]>() as wgpu::BufferAddress,
        step_mode: wgpu::VertexStepMode::Vertex,
        attributes: &[
            wgpu::VertexAttribute { offset: 0, shader_location: 0, format: wgpu::VertexFormat::Float32x3 },
            wgpu::VertexAttribute { offset: std::mem::size_of::<[f32; 3]>() as wgpu::BufferAddress, shader_location: 1, format: wgpu::VertexFormat::Float32x3 },
            wgpu::VertexAttribute { offset: std::mem::size_of::<[f32; 6]>() as wgpu::BufferAddress, shader_location: 2, format: wgpu::VertexFormat::Float32x2 },
            wgpu::VertexAttribute { offset: std::mem::size_of::<[f32; 8]>() as wgpu::BufferAddress, shader_location: 3, format: wgpu::VertexFormat::Float32x4 },
        ],
    };

    let instance_layout = wgpu::VertexBufferLayout {
        array_stride: 64,
        step_mode: wgpu::VertexStepMode::Instance,
        attributes: &[
            wgpu::VertexAttribute { offset: 0, shader_location: 4, format: wgpu::VertexFormat::Float32x4 },
            wgpu::VertexAttribute { offset: 16, shader_location: 5, format: wgpu::VertexFormat::Float32x4 },
            wgpu::VertexAttribute { offset: 32, shader_location: 6, format: wgpu::VertexFormat::Float32x4 },
            wgpu::VertexAttribute { offset: 48, shader_location: 7, format: wgpu::VertexFormat::Float32x4 },
        ],
    };

    let vertex_layouts = [per_vertex_layout, instance_layout];

    device.create_render_pipeline(&wgpu::RenderPipelineDescriptor {
        label: Some(&format!("nwn3d_{}_pipeline", label)),
        layout: Some(&device.create_pipeline_layout(&wgpu::PipelineLayoutDescriptor {
            label: Some(&format!("nwn3d_{}_pipeline_layout", label)),
            bind_group_layouts: &[uniform_bind_group_layout, texture_bind_group_layout],
            push_constant_ranges: &[],
        })),
        vertex: wgpu::VertexState {
            module: &shader,
            entry_point: Some("vs_main"),
            buffers: &vertex_layouts,
            compilation_options: Default::default(),
        },
        primitive: wgpu::PrimitiveState {
            topology: wgpu::PrimitiveTopology::TriangleList,
            strip_index_format: None,
            front_face: wgpu::FrontFace::Ccw,
            cull_mode: None,
            polygon_mode: wgpu::PolygonMode::Fill,
            unclipped_depth: false,
            conservative: false,
        },
        depth_stencil,
        multisample: wgpu::MultisampleState {
            count: 1,
            mask: !0,
            alpha_to_coverage_enabled: false,
        },
        fragment: Some(wgpu::FragmentState {
            module: &shader,
            entry_point: Some("fs_main"),
            targets: &[Some(wgpu::ColorTargetState {
                format: color_format,
                blend: Some(wgpu::BlendState {
                    color: wgpu::BlendComponent::OVER,
                    alpha: wgpu::BlendComponent::OVER,
                }),
                write_mask: wgpu::ColorWrites::ALL,
            })],
            compilation_options: Default::default(),
        }),
        multiview: None,
        cache: None,
    })
}

pub fn create_floor_pipeline(
    device: &wgpu::Device,
    color_format: wgpu::TextureFormat,
    uniform_bind_group_layout: &wgpu::BindGroupLayout,
    texture_bind_group_layout: &wgpu::BindGroupLayout,
    depth_format: Option<wgpu::TextureFormat>,
) -> wgpu::RenderPipeline {
    create_overlay_pipeline_impl("floor", device, color_format, uniform_bind_group_layout, texture_bind_group_layout, depth_format, create_depth_stencil_overlay(depth_format))
}

pub fn create_marker_pipeline(
    device: &wgpu::Device,
    color_format: wgpu::TextureFormat,
    uniform_bind_group_layout: &wgpu::BindGroupLayout,
    texture_bind_group_layout: &wgpu::BindGroupLayout,
    depth_format: Option<wgpu::TextureFormat>,
) -> wgpu::RenderPipeline {
    let depth_stencil = depth_format.map(|f| wgpu::DepthStencilState {
        format: f,
        depth_write_enabled: false,
        depth_compare: wgpu::CompareFunction::LessEqual,
        stencil: wgpu::StencilState::default(),
        bias: wgpu::DepthBiasState::default(),
    });
    create_overlay_pipeline_impl("marker", device, color_format, uniform_bind_group_layout, texture_bind_group_layout, depth_format, depth_stencil)
}

pub fn create_walkmesh_pipeline(
    device: &wgpu::Device,
    color_format: wgpu::TextureFormat,
    uniform_bind_group_layout: &wgpu::BindGroupLayout,
    texture_bind_group_layout: &wgpu::BindGroupLayout,
    depth_format: Option<wgpu::TextureFormat>,
) -> wgpu::RenderPipeline {
    create_overlay_pipeline_impl("walkmesh", device, color_format, uniform_bind_group_layout, texture_bind_group_layout, depth_format, create_depth_stencil_walkmesh(depth_format))
}

fn _create_pipeline_with_cull(
    device: &wgpu::Device,
    color_format: wgpu::TextureFormat,
    uniform_bind_group_layout: &wgpu::BindGroupLayout,
    texture_bind_group_layout: &wgpu::BindGroupLayout,
    depth_format: Option<wgpu::TextureFormat>,
    cull_mode: Option<wgpu::Face>,
) -> wgpu::RenderPipeline {
    let shader = device.create_shader_module(wgpu::ShaderModuleDescriptor {
        label: Some("nwn3d_shader"),
        source: wgpu::ShaderSource::Wgsl(VERTEX_SHADER.into()),
    });

    let per_vertex_layout = wgpu::VertexBufferLayout {
        array_stride: std::mem::size_of::<[f32; 12]>() as wgpu::BufferAddress,
        step_mode: wgpu::VertexStepMode::Vertex,
        attributes: &[
            wgpu::VertexAttribute {
                offset: 0,
                shader_location: 0,
                format: wgpu::VertexFormat::Float32x3,
            },
            wgpu::VertexAttribute {
                offset: std::mem::size_of::<[f32; 3]>() as wgpu::BufferAddress,
                shader_location: 1,
                format: wgpu::VertexFormat::Float32x3,
            },
            wgpu::VertexAttribute {
                offset: std::mem::size_of::<[f32; 6]>() as wgpu::BufferAddress,
                shader_location: 2,
                format: wgpu::VertexFormat::Float32x2,
            },
            wgpu::VertexAttribute {
                offset: std::mem::size_of::<[f32; 8]>() as wgpu::BufferAddress,
                shader_location: 3,
                format: wgpu::VertexFormat::Float32x4,
            },
        ],
    };

    let instance_layout = wgpu::VertexBufferLayout {
        array_stride: 64,
        step_mode: wgpu::VertexStepMode::Instance,
        attributes: &[
            wgpu::VertexAttribute { offset: 0, shader_location: 4, format: wgpu::VertexFormat::Float32x4 },
            wgpu::VertexAttribute { offset: 16, shader_location: 5, format: wgpu::VertexFormat::Float32x4 },
            wgpu::VertexAttribute { offset: 32, shader_location: 6, format: wgpu::VertexFormat::Float32x4 },
            wgpu::VertexAttribute { offset: 48, shader_location: 7, format: wgpu::VertexFormat::Float32x4 },
        ],
    };

    let vertex_layouts = [per_vertex_layout, instance_layout];

    device.create_render_pipeline(&wgpu::RenderPipelineDescriptor {
        label: Some("nwn3d_pipeline"),
        layout: Some(&device.create_pipeline_layout(&wgpu::PipelineLayoutDescriptor {
            label: Some("nwn3d_pipeline_layout"),
            bind_group_layouts: &[uniform_bind_group_layout, texture_bind_group_layout],
            push_constant_ranges: &[],
        })),
        vertex: wgpu::VertexState {
            module: &shader,
            entry_point: Some("vs_main"),
            buffers: &vertex_layouts,
            compilation_options: Default::default(),
        },
        primitive: wgpu::PrimitiveState {
            topology: wgpu::PrimitiveTopology::TriangleList,
            strip_index_format: None,
            front_face: wgpu::FrontFace::Ccw,
            cull_mode,
            polygon_mode: wgpu::PolygonMode::Fill,
            unclipped_depth: false,
            conservative: false,
        },
        depth_stencil: create_depth_stencil(depth_format),
        multisample: wgpu::MultisampleState {
            count: 1,
            mask: !0,
            alpha_to_coverage_enabled: false,
        },
        fragment: Some(wgpu::FragmentState {
            module: &shader,
            entry_point: Some("fs_main"),
            targets: &[Some(wgpu::ColorTargetState {
                format: color_format,
                blend: Some(wgpu::BlendState {
                    color: wgpu::BlendComponent::OVER,
                    alpha: wgpu::BlendComponent::OVER,
                }),
                write_mask: wgpu::ColorWrites::ALL,
            })],
            compilation_options: Default::default(),
        }),
        multiview: None,
        cache: None,
    })
}

pub const LINE_SHADER: &str = r#"
struct Uniforms {
    view_proj: mat4x4<f32>,
    ambient_color: vec4<f32>,
    fog_color: vec4<f32>,
    fog_params: vec4<f32>,
    camera_pos: vec4<f32>,
    diffuse_color: vec4<f32>,
}
@group(0) @binding(0) var<uniform> uniforms: Uniforms;

struct VertexInput {
    @location(0) position: vec3<f32>,
    @location(1) color: vec4<f32>,
}

struct VertexOutput {
    @builtin(position) position: vec4<f32>,
    @location(0) color: vec4<f32>,
}

@vertex
fn vs_main(input: VertexInput) -> VertexOutput {
    var output: VertexOutput;
    output.position = uniforms.view_proj * vec4<f32>(input.position, 1.0);
    output.color = input.color;
    return output;
}

@fragment
fn fs_main(input: VertexOutput) -> @location(0) vec4<f32> {
    return input.color;
}
"#;

pub fn create_highlight_pipeline(
    device: &wgpu::Device,
    color_format: wgpu::TextureFormat,
    uniform_bind_group_layout: &wgpu::BindGroupLayout,
) -> wgpu::RenderPipeline {
    let shader = device.create_shader_module(wgpu::ShaderModuleDescriptor {
        label: Some("nwn3d_highlight_shader"),
        source: wgpu::ShaderSource::Wgsl(LINE_SHADER.into()),
    });

    let vertex_layout = wgpu::VertexBufferLayout {
        array_stride: 28,
        step_mode: wgpu::VertexStepMode::Vertex,
        attributes: &[
            wgpu::VertexAttribute { offset: 0, shader_location: 0, format: wgpu::VertexFormat::Float32x3 },
            wgpu::VertexAttribute { offset: 12, shader_location: 1, format: wgpu::VertexFormat::Float32x4 },
        ],
    };

    device.create_render_pipeline(&wgpu::RenderPipelineDescriptor {
        label: Some("nwn3d_highlight_pipeline"),
        layout: Some(&device.create_pipeline_layout(&wgpu::PipelineLayoutDescriptor {
            label: Some("nwn3d_highlight_pipeline_layout"),
            bind_group_layouts: &[uniform_bind_group_layout],
            push_constant_ranges: &[],
        })),
        vertex: wgpu::VertexState {
            module: &shader,
            entry_point: Some("vs_main"),
            buffers: &[vertex_layout],
            compilation_options: Default::default(),
        },
        primitive: wgpu::PrimitiveState {
            topology: wgpu::PrimitiveTopology::LineList,
            strip_index_format: None,
            front_face: wgpu::FrontFace::Ccw,
            cull_mode: None,
            polygon_mode: wgpu::PolygonMode::Fill,
            unclipped_depth: false,
            conservative: false,
        },
        depth_stencil: Some(wgpu::DepthStencilState {
            format: wgpu::TextureFormat::Depth32Float,
            depth_write_enabled: false,
            depth_compare: wgpu::CompareFunction::Always,
            stencil: wgpu::StencilState::default(),
            bias: wgpu::DepthBiasState::default(),
        }),
        multisample: wgpu::MultisampleState {
            count: 1,
            mask: !0,
            alpha_to_coverage_enabled: false,
        },
        fragment: Some(wgpu::FragmentState {
            module: &shader,
            entry_point: Some("fs_main"),
            targets: &[Some(wgpu::ColorTargetState {
                format: color_format,
                blend: Some(wgpu::BlendState {
                    color: wgpu::BlendComponent::OVER,
                    alpha: wgpu::BlendComponent::OVER,
                }),
                write_mask: wgpu::ColorWrites::ALL,
            })],
            compilation_options: Default::default(),
        }),
        multiview: None,
        cache: None,
    })
}

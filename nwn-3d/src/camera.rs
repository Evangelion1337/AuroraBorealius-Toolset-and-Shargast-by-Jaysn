#[derive(Clone)]
pub struct OrbitCamera {
    pub theta: f32,
    pub phi: f32,
    pub radius: f32,
    pub target: [f32; 3],
    pub aspect: f32,
}

impl OrbitCamera {
    pub fn new(width: f32, height: f32) -> Self {
        let radius = (width.max(height) * 10.0 * 1.5).max(20.0);
        Self {
            theta: std::f32::consts::FRAC_PI_4,
            phi: std::f32::consts::FRAC_PI_6,
            radius,
            target: [width * 5.0, 0.0, -height * 5.0],
            aspect: 1.0,
        }
    }

    pub fn right_up(&self) -> ([f32; 3], [f32; 3]) {
        let (sin_t, cos_t) = self.theta.sin_cos();
        let (sin_p, cos_p) = self.phi.sin_cos();
        let forward = [-cos_p * sin_t, -sin_p, -cos_p * cos_t];
        let world_up = [0.0, 1.0, 0.0];
        let right = cross(forward, world_up);
        let up = cross(right, forward);
        (right, up)
    }

    pub fn eye(&self) -> [f32; 3] {
        let (sin_t, cos_t) = self.theta.sin_cos();
        let (sin_p, cos_p) = self.phi.sin_cos();
        [
            self.target[0] + self.radius * cos_p * sin_t,
            self.target[1] + self.radius * sin_p,
            self.target[2] + self.radius * cos_p * cos_t,
        ]
    }

    pub fn view_matrix(&self) -> [[f32; 4]; 4] {
        look_at(self.eye(), self.target, [0.0, 1.0, 0.0])
    }

    pub fn projection_matrix(&self) -> [[f32; 4]; 4] {
        perspective(60.0f32.to_radians(), self.aspect, 0.1, 10000.0)
    }

    pub fn rotate(&mut self, delta_x: f32, delta_y: f32) {
        self.theta += delta_x * 0.005;
        self.phi = (self.phi + delta_y * 0.005).clamp(-1.5, 1.5);
    }

    pub fn rotate_yaw(&mut self, delta_x: f32) {
        self.theta += delta_x * 0.005;
    }

    pub fn zoom(&mut self, delta: f32) {
        self.radius = (self.radius * (1.0 + delta * 0.01)).clamp(1.0, 5000.0);
    }

    pub fn pan(&mut self, delta_x: f32, delta_y: f32) {
        let (sin_t, cos_t) = self.theta.sin_cos();
        let (sin_p, cos_p) = self.phi.sin_cos();
        let forward = [-cos_p * sin_t, -sin_p, -cos_p * cos_t];
        let world_up = [0.0, 1.0, 0.0];
        let right = cross(forward, world_up);
        let up = cross(right, forward);
        let speed = self.radius * 0.002;
        self.target[0] += right[0] * -delta_x * speed + up[0] * delta_y * speed;
        self.target[1] += right[1] * -delta_x * speed + up[1] * delta_y * speed;
        self.target[2] += right[2] * -delta_x * speed + up[2] * delta_y * speed;
    }

    pub fn ray_from_screen(&self, screen_x: f32, screen_y: f32, view_w: f32, view_h: f32) -> ([f32; 3], [f32; 3]) {
        if view_w <= 0.0 || view_h <= 0.0 { return ([0.0, 0.0, 0.0], [0.0, 1.0, 0.0]); }
        let ndc_x = 2.0 * screen_x / view_w - 1.0;
        let ndc_y = 1.0 - 2.0 * screen_y / view_h;
        let (sin_t, cos_t) = self.theta.sin_cos();
        let (sin_p, cos_p) = self.phi.sin_cos();
        let eye = [
            self.target[0] + self.radius * cos_p * sin_t,
            self.target[1] + self.radius * sin_p,
            self.target[2] + self.radius * cos_p * cos_t,
        ];
        let fwd = normalize([self.target[0] - eye[0], self.target[1] - eye[1], self.target[2] - eye[2]]);
        let world_up = [0.0, 1.0, 0.0];
        let right = cross(fwd, world_up);
        let up = cross(right, fwd);
        let tan_hfov = (60.0f32.to_radians() * 0.5).tan();
        let ray_dir = normalize([
            fwd[0] + ndc_x * self.aspect * tan_hfov * right[0] + ndc_y * tan_hfov * up[0],
            fwd[1] + ndc_x * self.aspect * tan_hfov * right[1] + ndc_y * tan_hfov * up[1],
            fwd[2] + ndc_x * self.aspect * tan_hfov * right[2] + ndc_y * tan_hfov * up[2],
        ]);
        (eye, ray_dir)
    }

    pub fn world_to_screen(&self, world: [f32; 3], view_w: f32, view_h: f32) -> Option<[f32; 2]> {
        if view_w <= 0.0 || view_h <= 0.0 { return None; }
        let vp = mat4_mul(self.view_matrix(), self.projection_matrix());
        let mut clip = [
            vp[0][0] * world[0] + vp[1][0] * world[1] + vp[2][0] * world[2] + vp[3][0],
            vp[0][1] * world[0] + vp[1][1] * world[1] + vp[2][1] * world[2] + vp[3][1],
            vp[0][2] * world[0] + vp[1][2] * world[1] + vp[2][2] * world[2] + vp[3][2],
            vp[0][3] * world[0] + vp[1][3] * world[1] + vp[2][3] * world[2] + vp[3][3],
        ];
        if clip[3].abs() < 1e-15 { return None; }
        let inv_w = 1.0 / clip[3];
        clip[0] *= inv_w;
        clip[1] *= inv_w;
        clip[2] *= inv_w;
        let sx = (clip[0] * 0.5 + 0.5) * view_w;
        let sy = (1.0 - (clip[1] * 0.5 + 0.5)) * view_h;
        Some([sx, sy])
    }

    pub fn walk(&mut self, forward_input: f32, right_input: f32) {
        let (sin_t, cos_t) = self.theta.sin_cos();
        let (_sin_p, cos_p) = self.phi.sin_cos();
        // Horizontal forward direction (projected onto XZ plane)
        let mut fwd_x = -cos_p * sin_t;
        let mut fwd_z = -cos_p * cos_t;
        let len = (fwd_x * fwd_x + fwd_z * fwd_z).sqrt();
        if len > 0.0 { fwd_x /= len; fwd_z /= len; }
        let rgt_x = -fwd_z;
        let rgt_z = fwd_x;
        let speed = 0.3;
        self.target[0] += (fwd_x * forward_input + rgt_x * right_input) * speed;
        self.target[2] += (fwd_z * forward_input + rgt_z * right_input) * speed;
    }
}

fn look_at(eye: [f32; 3], target: [f32; 3], up: [f32; 3]) -> [[f32; 4]; 4] {
    let fwd = normalize([target[0] - eye[0], target[1] - eye[1], target[2] - eye[2]]);
    let side = cross(fwd, up);
    let up2 = cross(side, fwd);
    [
        [side[0], up2[0], -fwd[0], 0.0],
        [side[1], up2[1], -fwd[1], 0.0],
        [side[2], up2[2], -fwd[2], 0.0],
        [-dot(side, eye), -dot(up2, eye), dot(fwd, eye), 1.0],
    ]
}

fn perspective(fov_y: f32, aspect: f32, near: f32, far: f32) -> [[f32; 4]; 4] {
    let f = 1.0 / (fov_y * 0.5).tan();
    let range_inv = 1.0 / (near - far);
    [
        [f / aspect, 0.0, 0.0, 0.0],
        [0.0, f, 0.0, 0.0],
        [0.0, 0.0, far * range_inv, -1.0],
        [0.0, 0.0, far * near * range_inv, 0.0],
    ]
}

fn normalize(v: [f32; 3]) -> [f32; 3] {
    let len = (v[0] * v[0] + v[1] * v[1] + v[2] * v[2]).sqrt();
    if len == 0.0 { return [0.0, 0.0, 0.0]; }
    [v[0] / len, v[1] / len, v[2] / len]
}

fn cross(a: [f32; 3], b: [f32; 3]) -> [f32; 3] {
    [
        a[1] * b[2] - a[2] * b[1],
        a[2] * b[0] - a[0] * b[2],
        a[0] * b[1] - a[1] * b[0],
    ]
}

fn dot(a: [f32; 3], b: [f32; 3]) -> f32 {
    a[0] * b[0] + a[1] * b[1] + a[2] * b[2]
}

pub fn mat4_mul(a: [[f32; 4]; 4], b: [[f32; 4]; 4]) -> [[f32; 4]; 4] {
    let mut out = [[0.0f32; 4]; 4];
    for i in 0..4 {
        for j in 0..4 {
            out[i][j] = a[i][0] * b[0][j] + a[i][1] * b[1][j] + a[i][2] * b[2][j] + a[i][3] * b[3][j];
        }
    }
    out
}

fn det4x4(m: &[[f32; 4]; 4]) -> f32 {
    let a2323 = m[2][2] * m[3][3] - m[2][3] * m[3][2];
    let a1323 = m[2][1] * m[3][3] - m[2][3] * m[3][1];
    let a1223 = m[2][1] * m[3][2] - m[2][2] * m[3][1];
    let a0323 = m[2][0] * m[3][3] - m[2][3] * m[3][0];
    let a0223 = m[2][0] * m[3][2] - m[2][2] * m[3][0];
    let a0123 = m[2][0] * m[3][1] - m[2][1] * m[3][0];
    m[0][0] * (m[1][1] * a2323 - m[1][2] * a1323 + m[1][3] * a1223)
    - m[0][1] * (m[1][0] * a2323 - m[1][2] * a0323 + m[1][3] * a0223)
    + m[0][2] * (m[1][0] * a1323 - m[1][1] * a0323 + m[1][3] * a0123)
    - m[0][3] * (m[1][0] * a1223 - m[1][1] * a0223 + m[1][2] * a0123)
}

pub fn mat4_inverse(m: [[f32; 4]; 4]) -> [[f32; 4]; 4] {
    let det = det4x4(&m);
    if det.abs() < 1e-15 { return m; }
    let inv_det = 1.0 / det;
    let m00 = m[0][0]; let m01 = m[0][1]; let m02 = m[0][2]; let m03 = m[0][3];
    let m10 = m[1][0]; let m11 = m[1][1]; let m12 = m[1][2]; let m13 = m[1][3];
    let m20 = m[2][0]; let m21 = m[2][1]; let m22 = m[2][2]; let m23 = m[2][3];
    let m30 = m[3][0]; let m31 = m[3][1]; let m32 = m[3][2]; let m33 = m[3][3];
    [
        [ (m11*(m22*m33 - m23*m32) - m12*(m21*m33 - m23*m31) + m13*(m21*m32 - m22*m31)) * inv_det,
          -(m01*(m22*m33 - m23*m32) - m02*(m21*m33 - m23*m31) + m03*(m21*m32 - m22*m31)) * inv_det,
           (m01*(m12*m33 - m13*m32) - m02*(m11*m33 - m13*m31) + m03*(m11*m32 - m12*m31)) * inv_det,
          -(m01*(m12*m23 - m13*m22) - m02*(m11*m23 - m13*m21) + m03*(m11*m22 - m12*m21)) * inv_det ],
        [ -(m10*(m22*m33 - m23*m32) - m12*(m20*m33 - m23*m30) + m13*(m20*m32 - m22*m30)) * inv_det,
           (m00*(m22*m33 - m23*m32) - m02*(m20*m33 - m23*m30) + m03*(m20*m32 - m22*m30)) * inv_det,
          -(m00*(m12*m33 - m13*m32) - m02*(m10*m33 - m13*m30) + m03*(m10*m32 - m12*m30)) * inv_det,
           (m00*(m12*m23 - m13*m22) - m02*(m10*m23 - m13*m20) + m03*(m10*m22 - m12*m20)) * inv_det ],
        [ (m10*(m21*m33 - m23*m31) - m11*(m20*m33 - m23*m30) + m13*(m20*m31 - m21*m30)) * inv_det,
          -(m00*(m21*m33 - m23*m31) - m01*(m20*m33 - m23*m30) + m03*(m20*m31 - m21*m30)) * inv_det,
           (m00*(m11*m33 - m13*m31) - m01*(m10*m33 - m13*m30) + m03*(m10*m31 - m11*m30)) * inv_det,
          -(m00*(m11*m23 - m13*m21) - m01*(m10*m23 - m13*m20) + m03*(m10*m21 - m11*m20)) * inv_det ],
        [ -(m10*(m21*m32 - m22*m31) - m11*(m20*m32 - m22*m30) + m12*(m20*m31 - m21*m30)) * inv_det,
           (m00*(m21*m32 - m22*m31) - m01*(m20*m32 - m22*m30) + m02*(m20*m31 - m21*m30)) * inv_det,
          -(m00*(m11*m32 - m12*m31) - m01*(m10*m32 - m12*m30) + m02*(m10*m31 - m11*m30)) * inv_det,
           (m00*(m11*m22 - m12*m21) - m01*(m10*m22 - m12*m20) + m02*(m10*m21 - m11*m20)) * inv_det ],
    ]
}

#[allow(dead_code)]
fn transform_vec4(m: &[[f32; 4]; 4], v: [f32; 4]) -> [f32; 4] {
    [
        m[0][0] * v[0] + m[0][1] * v[1] + m[0][2] * v[2] + m[0][3] * v[3],
        m[1][0] * v[0] + m[1][1] * v[1] + m[1][2] * v[2] + m[1][3] * v[3],
        m[2][0] * v[0] + m[2][1] * v[1] + m[2][2] * v[2] + m[2][3] * v[3],
        m[3][0] * v[0] + m[3][1] * v[1] + m[3][2] * v[2] + m[3][3] * v[3],
    ]
}

#[cfg(test)]
mod camera_projection_tests {
    use super::*;

    fn assert_near(actual: f32, expected: f32) {
        assert!(
            (actual - expected).abs() < 0.01,
            "expected {expected}, got {actual}"
        );
    }

    #[test]
    fn target_projects_to_viewport_center() {
        let mut camera = OrbitCamera::new(4.0, 3.0);
        camera.aspect = 800.0 / 600.0;

        let point = camera
            .world_to_screen(camera.target, 800.0, 600.0)
            .expect("camera target should project");

        assert_near(point[0], 400.0);
        assert_near(point[1], 300.0);
    }

    #[test]
    fn right_and_up_project_in_expected_directions() {
        let mut camera = OrbitCamera::new(4.0, 3.0);
        camera.aspect = 800.0 / 600.0;

        let (right, up) = camera.right_up();

        let right_point = [
            camera.target[0] + right[0],
            camera.target[1] + right[1],
            camera.target[2] + right[2],
        ];
        let up_point = [
            camera.target[0] + up[0],
            camera.target[1] + up[1],
            camera.target[2] + up[2],
        ];

        let right_screen = camera
            .world_to_screen(right_point, 800.0, 600.0)
            .unwrap();

        let up_screen = camera
            .world_to_screen(up_point, 800.0, 600.0)
            .unwrap();

        assert!(right_screen[0] > 400.0);
        assert_near(right_screen[1], 300.0);

        assert!(up_screen[1] < 300.0);
        assert_near(up_screen[0], 400.0);
    }
}

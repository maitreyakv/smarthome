use axum::{http::StatusCode, routing::post, Router};
use wizctl::devices::Device;

#[tokio::main]
async fn main() {
    let app = Router::new()
        .route("/kitchen/on", post(kitchen_on))
        .route("/kitchen/off", post(kitchen_off))
        .route("/living-room/on", post(living_room_on))
        .route("/living-room/off", post(living_roon_off))
        .route("/bedroom/on", post(bedroom_on))
        .route("/bedroom/off", post(bedroom_off));
    let listener = tokio::net::TcpListener::bind("127.0.0.1:3000")
        .await
        .unwrap();
    axum::serve(listener, app).await.unwrap();
}


async fn living_room_on() -> Result<StatusCode, StatusCode> {
    lights_on(vec!["10.0.0.131", "10.0.0.121", "10.0.0.235", "10.0.0.79", "10.0.0.92"]).await
}

async fn living_roon_off() -> Result<StatusCode, StatusCode> {
    lights_off(vec!["10.0.0.131", "10.0.0.121", "10.0.0.235", "10.0.0.79", "10.0.0.92"]).await
}

async fn kitchen_off() -> Result<StatusCode, StatusCode> {
    lights_off(vec!["10.0.0.171", "10.0.0.211"]).await
}

async fn kitchen_on() -> Result<StatusCode, StatusCode> {
    lights_on(vec!["10.0.0.171", "10.0.0.211"]).await
}


async fn bedroom_on() -> Result<StatusCode, StatusCode> {
    lights_off(vec!["10.0.0.212", "10.0.0.139"]).await
}

async fn bedroom_off() -> Result<StatusCode, StatusCode> {
    lights_on(vec!["10.0.0.212", "10.0.0.139"]).await
}

async fn lights_on(ips: Vec<&'static str>) -> Result<StatusCode, StatusCode> {
    ips.into_iter()
        .map(|ip| {
            return Device::connect(ip.parse().unwrap())
                .map_err(|e| {
                    println!("{e}");
                    return StatusCode::INTERNAL_SERVER_ERROR
                })?
                .set_pilot()
                .on()
                .send()
                .map_err(|e| {
                    println!("{e}");
                    return StatusCode::INTERNAL_SERVER_ERROR
                })
        })
        .collect::<Result<Vec<_>, _>>()
        .map_err(|e| {
            println!("{e}");
            return StatusCode::INTERNAL_SERVER_ERROR
        })?;
    Ok(StatusCode::OK)
}

async fn lights_off(ips: Vec<&'static str>) -> Result<StatusCode, StatusCode> {
    ips.into_iter()
        .map(|ip| {
            return Device::connect(ip.parse().unwrap())
                .map_err(|e| {
                    println!("{e}");
                    return StatusCode::INTERNAL_SERVER_ERROR
                })?
                .set_pilot()
                .off()
                .send()
                .map_err(|e| {
                    println!("{e}");
                    return StatusCode::INTERNAL_SERVER_ERROR
                })
        })
        .collect::<Result<Vec<_>, _>>()
        .map_err(|e| {
            println!("{e}");
            return StatusCode::INTERNAL_SERVER_ERROR
        })?;
    Ok(StatusCode::OK)
}

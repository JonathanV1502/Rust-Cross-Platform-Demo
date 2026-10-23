use std::env;
use std::process::ExitCode;

fn is_even(n: i128) -> bool {
    n % 2 == 0
}

fn main() -> ExitCode {
    let Some(arg) = env::args().nth(1) else {
        eprintln!("usage: odd-even <integer>");
        return ExitCode::from(2);
    };
    let arg = arg.trim();

    match arg.parse::<i128>() {
        Ok(n) => {
            println!("{n} is {}", if is_even(n) { "even" } else { "odd" });
            ExitCode::SUCCESS
        }
        Err(_) => {
            eprintln!("error: '{arg}' is not an integer");
            ExitCode::from(1)
        }
    }
}

#[cfg(test)]
mod tests {
    use super::is_even;

    #[test]
    fn zero_is_even() {
        assert!(is_even(0));
    }

    #[test]
    fn positives() {
        assert!(is_even(4));
        assert!(!is_even(7));
    }

    #[test]
    fn negatives() {
        assert!(is_even(-4));
        assert!(!is_even(-7));
    }

    #[test]
    fn extremes() {
        assert!(is_even(i128::MIN));
        assert!(!is_even(i128::MAX));
    }
}

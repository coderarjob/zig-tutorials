trait PriterWithTypeName {
    fn print(&self);
}

impl PriterWithTypeName for i32 {
    fn print(&self) {
        println!("integer: {}", self);
    }
}

impl PriterWithTypeName for f32 {
    fn print(&self) {
        (*self as f64).print();
    }
}

impl PriterWithTypeName for f64 {
    fn print(&self) {
        println!("float: {}", self);
    }
}

fn print<T: PriterWithTypeName>(n: T) {
    n.print();
}

fn main() {
    print(10);
    print(1.24);
    print(1.24 as f64);
}

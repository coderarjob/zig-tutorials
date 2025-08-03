#![allow(unused)]

trait SearableList {
    fn compare(&self, b: &Self) -> bool;
}

struct List<'a, T: SearableList> {
    inner_list: Vec<&'a T>,
}

impl<'a, T: SearableList> List<'a, T> {
    pub fn new(capacity: usize) -> Self {
        Self {
            inner_list: Vec::<&T>::with_capacity(capacity),
        }
    }

    pub fn insert(&mut self, item: &'a T) {
        self.inner_list.push(item);
    }

    pub fn search(&self, item: &T) -> bool {
        for il in &self.inner_list {
            if il.compare(item) {
                return true;
            }
        }
        false
    }
}

struct Person(u32);
impl SearableList for Person {
    fn compare(&self, b: &Self) -> bool {
        self.0 == b.0
    }
}

struct Animal(u32);
impl SearableList for Animal {
    fn compare(&self, b: &Self) -> bool {
        self.0 == b.0
    }
}

fn main() {
    let mut person_list = List::<Person>::new(100);
    person_list.insert(&Person(10));
    person_list.insert(&Person(12));
    person_list.insert(&Person(14));

    let p = Person(14);
    dbg!(person_list.search(&p));

    let mut animal_list = List::<Animal>::new(100);
    animal_list.insert(&Animal(210));
    animal_list.insert(&Animal(212));
    animal_list.insert(&Animal(214));

    let a = Animal(214);
    dbg!(animal_list.search(&a));
}

//
//  vector_t.cpp
//  TrazoCore
//
//  Created by Juan Hurtado on 11/03/25.
//

#include "vector_t.hpp"

// MARK: - Member operators
vector_t vector_t::operator+(const vector_t& other) const {
    return vector_t(x + other.x, y + other.y);
}

vector_t vector_t::operator-(const vector_t& other) const {
    return vector_t(x - other.x, y - other.y);
}

vector_t vector_t::operator/(float scalar) const {
    return vector_t(x / scalar, y / scalar);
}


// MARK: - Non-member operators
vector_t operator*(const vector_t& vector, float scalar) {
    return vector_t(vector.x * scalar, vector.y * scalar);
}

vector_t operator*(float scalar, const vector_t& vector) {
    return vector_t(vector.x * scalar, vector.y * scalar);
}

// MARK: Methods
float vector_t::distance_to(const vector_t &vector) const {
    return sqrt(pow(x - vector.x, 2) + pow(y - vector.y, 2));
}


